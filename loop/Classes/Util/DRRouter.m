//
//  DRRouter.m
//  loop
//
//  Created by doom on 16/8/1.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRRouter.h"
#import "DRViewController.h"
#import "MMDrawerController.h"
#import "DRUser.h"
#import "NSObject+ResponseCache.h"

static NSString *const kUserCacheKey = @"userCache";

@interface DRRouter ()

@property(nonatomic, copy) NSDictionary *viewModelViewMappings; // viewModel到view的映射

@end

@implementation DRRouter

@synthesize user = _user;

+ (instancetype)sharedInstance {
    static DRRouter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (DRViewController *)viewControllerForViewModel:(DRViewModel *)viewModel {
    NSString *viewController = self.viewModelViewMappings[NSStringFromClass(viewModel.class)];

    NSParameterAssert([NSClassFromString(viewController) isSubclassOfClass:[DRViewController class]]);
    NSParameterAssert([NSClassFromString(viewController) instancesRespondToSelector:@selector(initWithViewModel:)]);

    return [(DRViewController *) [NSClassFromString(viewController) alloc] initWithViewModel:viewModel];
}

- (NSDictionary *)viewModelViewMappings {
    return @{
            @"DRLoginViewModel": @"DRLoginViewController",
            @"DRMainViewModel": @"DRMainViewController",
            @"DRShotDetailViewModel": @"DRShotDetailViewController",
            @"DRUserViewModel": @"DRUserViewController",
            @"DRShotViewModel": @"DRShotViewController",
            @"DRUserListViewModel": @"DRUserListViewController",
            @"DRWebViewModel": @"DRWebViewController",
    };
}

#pragma mark user

- (DRUser *)currentUser {
    if (!_user) {
        _user = [NSObject loadKeyedArchiverResponseWithPath:kUserCacheKey];
    }
    return _user;
}

- (void)setUser:(DRUser *)user {
    _user = user;
    if (user) {
        [NSObject saveKeyedArchiverResponseData:user toPath:kUserCacheKey];
    } else {
        [NSObject deleteKeyedArchiverResponseCacheForPath:kUserCacheKey];
    }

}

@end
