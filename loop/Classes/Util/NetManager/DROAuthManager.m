//
//  DROAuthManager.m
//
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DROAuthManager.h"
#import "DRApiClient.h"
#import "NXOAuth2.h"
#import "DRApiClientSettings.h"

@interface DROAuthManager ()

@property(weak, nonatomic) UIWebView *webView;

@property(strong, nonatomic) id <NSObject> authCompletionObserver;
@property(strong, nonatomic) id <NSObject> authErrorObserver;

@property(copy, nonatomic) NSString *redirectUrl;
@property(copy, nonatomic) DROAuthHandler authHandler;

@end

@implementation DROAuthManager


#pragma mark - OAuth2 Logic

- (void)authorizeWithWebView:(UIWebView *)webView settings:(DRApiClientSettings *)settings authHandler:(DROAuthHandler)authHandler {
    self.authHandler = authHandler;

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (self.authCompletionObserver) [notificationCenter removeObserver:self.authCompletionObserver];
    if (self.authErrorObserver) [notificationCenter removeObserver:self.authErrorObserver];
    __weak typeof(self) weakSelf = self;

    self.authCompletionObserver = [notificationCenter addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification object:[NXOAuth2AccountStore sharedStore] queue:nil usingBlock:^(NSNotification *aNotification) {
        NXOAuth2Account *account = [[aNotification userInfo] objectForKey:NXOAuth2AccountStoreNewAccountUserInfoKey];
        if (account.accessToken.accessToken) {
            [weakSelf finalizeAuthWithAccount:account error:nil];
        } else {
            [weakSelf finalizeAuthWithAccount:nil error:[NSError errorWithDomain:kDROAuthErrorDomain code:kHttpAuthErrorCode userInfo:nil]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:weakSelf.authCompletionObserver];
    }];
    self.authErrorObserver = [notificationCenter addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification object:[NXOAuth2AccountStore sharedStore] queue:nil usingBlock:^(NSNotification *aNotification) {
        NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];

        NSData *responseData = error.userInfo[@"responseData"];
        if (responseData) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            NSString *errorText = responseDict[@"error"];
            NSString *errorDesc = responseDict[@"error_description"];
            NSDictionary *userInfo = nil;
            if (errorText && errorDesc) {
                userInfo = @{NSLocalizedDescriptionKey: errorDesc, kDROAuthErrorFailureKey: errorText, NSUnderlyingErrorKey: error};
            }
            NSError *bodyError = [[NSError alloc] initWithDomain:kDROAuthErrorDomain code:kHttpAuthErrorCode userInfo:userInfo];
            [weakSelf finalizeAuthWithAccount:nil error:bodyError];
        } else {
            [weakSelf finalizeAuthWithAccount:nil error:error];
        }

        [[NSNotificationCenter defaultCenter] removeObserver:weakSelf.authErrorObserver];
    }];

    [self requestAuthorizationWebView:webView withSettings:settings];
}

#pragma mark - WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)isUrlRedirectUrl:(NSURL *)url {
    NSURL *authUrl = [NSURL URLWithString:self.redirectUrl];
    return ([[authUrl host] isEqualToString:url.host] && [[authUrl scheme] isEqualToString:url.scheme]);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self isUrlRedirectUrl:request.URL]) {
        self.webView.userInteractionEnabled = YES;
        NSDictionary *params = [self paramsFromUrl:request.URL];
        if ([params objectForKey:@"code"]) {
            [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kIDMOAccountType] enumerateObjectsUsingBlock:^(NXOAuth2Account *obj, NSUInteger idx, BOOL *stop) {
                [[NXOAuth2AccountStore sharedStore] removeAccount:obj];
            }];
            [[NXOAuth2AccountStore sharedStore] handleRedirectURL:request.URL];
        } else {
            self.webView.userInteractionEnabled = NO;
        }
        return NO;
    } else if ([request.URL.absoluteString rangeOfString:kUnacceptableWebViewUrl options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSError *error = [NSError errorWithDomain:kDROAuthErrorDomain code:kDROAuthErrorCodeUnacceptableRedirectUrl userInfo:@{NSLocalizedDescriptionKey: kDROAuthErrorUnacceptableRedirectUrlDescription}];
        [self finalizeAuthWithAccount:nil error:error];
        return NO;
    }

    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSString *urlString = error.userInfo[NSURLErrorFailingURLStringErrorKey];
    if (urlString && [self isUrlRedirectUrl:[NSURL URLWithString:urlString]]) {
        // nop
    } else {
        // 有时候莫名奇妙失败了就。。。
//        [self finalizeAuthWithAccount:nil error:error];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Helpers

- (void)finalizeAuthWithAccount:(NXOAuth2Account *)account error:(NSError *)error {
    if (self.authHandler) {
        self.authHandler(account, error);
        self.authHandler = nil;

        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        if (self.authCompletionObserver) [notificationCenter removeObserver:self.authCompletionObserver];
        if (self.authErrorObserver) [notificationCenter removeObserver:self.authErrorObserver];
        self.authCompletionObserver = nil;
        self.authErrorObserver = nil;
    }
}

- (void)requestAuthorizationWebView:(UIWebView *)webView withSettings:(DRApiClientSettings *)settings {
    self.webView = webView;
    self.webView.delegate = self;

    NXOAuth2AccountStore *accountStore = [NXOAuth2AccountStore sharedStore];
    [accountStore setClientID:settings.clientId
                       secret:settings.clientSecret
                        scope:settings.scopes
             authorizationURL:[NSURL URLWithString:settings.oAuth2AuthorizationUrl]
                     tokenURL:[NSURL URLWithString:settings.oAuth2TokenUrl]
                  redirectURL:[NSURL URLWithString:settings.oAuth2RedirectUrl]
                keyChainGroup:kIDMOAccountType
               forAccountType:kIDMOAccountType];
    self.redirectUrl = settings.oAuth2RedirectUrl;

    [accountStore requestAccessToAccountWithType:kIDMOAccountType withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:preparedURL];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [webView loadRequest:request];
    }];
}


- (NSMutableDictionary *)paramsFromUrl:(NSURL *)url {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in [[url query] componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if ([elts count] == 2) {
            [params setObject:[elts lastObject] forKey:[elts firstObject]];
        }
    }
    return params;
}
@end
