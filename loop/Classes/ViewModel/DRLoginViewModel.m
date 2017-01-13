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

@implementation DRLoginViewModel

- (void)initCommand {
    [super initCommand];
    self.title = @"Login";

    @weakify(self)
    self.authCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIWebView *webView) {
        @strongify(self)
        return [[[DRApiClient sharedClient] authorizeWithWebView:webView] takeUntil:self.rac_willDeallocSignal];
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

@end
