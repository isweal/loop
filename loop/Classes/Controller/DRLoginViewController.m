//
//  DRLoginViewController.m
//  loop
//
//  Created by doom on 16/7/4.
//  Copyright © 2016年 DOOM. All rights reserved.
//


#import "DRLoginViewController.h"

#import "DRLoginViewModel.h"
#import "DRApiClient.h"
#import "NXOAuth2.h"

@interface DRLoginViewController ()

@property(nonatomic, strong, readonly) DRLoginViewModel *viewModel;

@end

@implementation DRLoginViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    cancelItem.rac_command = self.viewModel.cancelCommand;
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self.viewModel.authCommand execute:self.webView] deliverOnMainThread];
}

#pragma mark - WebView Delegate

- (BOOL)isUrlRedirectUrl:(NSURL *)url {
    NSURL *authUrl = [NSURL URLWithString:self.viewModel.redirectUrl];
    return ([[authUrl host] isEqualToString:url.host] && [[authUrl scheme] isEqualToString:url.scheme]);
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    if ([self isUrlRedirectUrl:request.URL]) {
        webView.userInteractionEnabled = YES;
        NSDictionary *params = [self paramsFromUrl:request.URL];
        if ([params objectForKey:@"code"]) {
            [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kIDMOAccountType] enumerateObjectsUsingBlock:^(NXOAuth2Account *obj, NSUInteger idx, BOOL *stop) {
                [[NXOAuth2AccountStore sharedStore] removeAccount:obj];
            }];
            [[NXOAuth2AccountStore sharedStore] handleRedirectURL:request.URL];
        } else {
            webView.userInteractionEnabled = NO;
        }
        return NO;
    } else if ([request.URL.absoluteString rangeOfString:kUnacceptableWebViewUrl options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSError *error = [NSError errorWithDomain:kDROAuthErrorDomain code:kDROAuthErrorCodeUnacceptableRedirectUrl userInfo:@{NSLocalizedDescriptionKey: kDROAuthErrorUnacceptableRedirectUrlDescription}];
        [self.viewModel finalizeAuthWithAccount:nil error:error];
        return NO;
    }

    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [super webView:webView didFailLoadWithError:error];
    NSString *urlString = error.userInfo[NSURLErrorFailingURLStringErrorKey];
    if (urlString && [self isUrlRedirectUrl:[NSURL URLWithString:urlString]]) {
        // nop
    } else {
        // 有时候莫名奇妙失败了就。。。
//        [self finalizeAuthWithAccount:nil error:error];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
