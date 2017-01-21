//
//  DRLoginViewModel.m
//  loop
//
//  Created by doom on 2016/9/27.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRLoginViewModel.h"

#import "DRApiClient.h"
#import "DRApiResponse.h"
#import "NXOAuth2.h"
#import "DRApiClientSettings.h"
#import "JDStatusBarNotification.h"

@interface DRLoginViewModel ()

@property(strong, nonatomic) id <NSObject> authCompletionObserver;
@property(strong, nonatomic) id <NSObject> authErrorObserver;

@property(copy, nonatomic) DROAuthHandler authHandler;

@end

@implementation DRLoginViewModel

- (void)dealloc {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (self.authCompletionObserver) [notificationCenter removeObserver:self.authCompletionObserver];
    if (self.authErrorObserver) [notificationCenter removeObserver:self.authErrorObserver];
}

- (void)initCommand {
    [super initCommand];
    self.title = @"Login";

    @weakify(self)
    self.authCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIWebView *webView) {
        @strongify(self)
        return [[self authorizeWithWebView:webView] takeUntil:self.rac_willDeallocSignal];
    }];

    // https://github.com/ReactiveCocoa/ReactiveCocoa/issues/1392
    self.authSuccessSignal = [[self.authCommand.executionSignals
            // subscribeSignal represents a single execution
            map:^(RACSignal *subscribeSignal) {
                // When the execution completes
                RACSignal *thanks = [[[subscribeSignal materialize] filter:^BOOL(RACEvent *event) {
                    return event.eventType == RACEventTypeCompleted;
                }].deliverOnMainThread
                        // Send the string "Thanks"
                        map:^id(id value) {
                            @strongify(self)
                            [self.services dismissViewModelAnimated:YES completion:nil];
                            BOOL userAuth = [DRApiClient sharedClient].isUserAuthorized;
                            if (userAuth) {
                                [[[DRApiClient sharedClient] loadUserInfo] subscribeNext:^(DRApiResponse *response) {
                                    DRUser *user = response.object;
                                    [DRRouter sharedInstance].user = user;
                                }];
                            }
                            // cancelCommand触发时也会调用这里，使用userAuthorized来做一个判断了
                            return @(userAuth);
                        }];

                // thanks is a RACSignal<NSString> (signal that sends strings)
                // The result of the map is a RACSignal<RACSignal<NSString>>
                return thanks;
            }]

            // Subscribe to every RACSignal<NSString> that comes out of the map
            // and create a RACSignal<NSString> that sends all the strings from all those signals
            flatten];
    // or
//    self.authSuccessSignal = [[[[self.authCommand.executionSignals
//            map:^(RACSignal *signal) {
//                return [signal materialize];
//            }]
//            switchToLatest]
//            filter:^BOOL(RACEvent *event) {
//                return event.eventType == RACEventTypeCompleted;
//            }]
//            mapReplace:@"Thanks"];

    [[[self.authCommand.errors filter:[self requestRemoteDataErrorsFilter]] doNext:^(id x) {
        @strongify(self)
        [self.services dismissViewModelAnimated:YES completion:nil];
    }] subscribe:self.errors];

    self.cancelCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self.services dismissViewModelAnimated:YES completion:nil];
        return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            [subscriber sendNext:@(YES)];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
}

- (BOOL (^)(NSError *error))requestRemoteDataErrorsFilter {
    return ^BOOL(NSError *error) {
        return YES;
    };
}

#pragma mark - OAuth2 Logic

- (RACSignal *)authorizeWithWebView:(UIWebView *)webView {
    @weakify(self)
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        [self authorizeWithWebView:webView settings:[DRApiClient sharedClient].settings authHandler:^(NXOAuth2Account *account, NSError *error) {
            if (!error && account) {
                if (account.accessToken.accessToken.length > 0) {
                    [[DRApiClient sharedClient] authWithAccessToken:account.accessToken.accessToken];
                    [subscriber sendNext:@(YES)];
                    [subscriber sendCompleted];
                    [JDStatusBarNotification showWithStatus:@"auth success" dismissAfter:2];
                } else {
                    [subscriber sendError:[NSError errorWithDomain:@"token error" code:66 userInfo:nil]];
                }
            } else {
                [[DRApiClient sharedClient] authWithAccessToken:nil];
                [subscriber sendError:error];
            }
        }];
        return nil;
    }] replayLazily];
}

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

@end
