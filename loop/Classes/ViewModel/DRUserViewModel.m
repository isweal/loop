//
//  DRUserViewModel.m
//  loop
//
//  Created by doom on 2016/10/20.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRUserViewModel.h"
#import "DRShotDetailViewModel.h"
#import "DRUserListViewModel.h"
#import "DRWebViewModel.h"
#import "DRLoginViewModel.h"

#import "DRUser.h"

#import "DRApiClient.h"
#import "DRApiResponse.h"
#import "DRShot.h"

@implementation DRUserViewModel

- (instancetype)initWithService:(id <DRViewModelServices>)services andParams:(NSDictionary *)params {
    self = [super initWithService:services andParams:params];
    if (self) {
        self.user = params[@"user"];
        self.userId = params[@"userId"] ?: self.user.userId;
        self.isLoadMySelf = [params[@"isLoadMySelf"] length] > 0;
    }
    return self;
}

- (void)initCommand {
    [super initCommand];

    RACSignal *isLoadSelfSignal = RACObserve(self, isLoadMySelf);
    self.showLogOutItemSignal = [[RACSignal combineLatest:@[isLoadSelfSignal, RACObserve([DRApiClient sharedClient], userAuthorized)]
                                                   reduce:^id(NSNumber *isLoadMySelf, NSNumber *isAuth) {
                                                       return @(isLoadMySelf.boolValue && isAuth.boolValue);
                                                   }] takeUntil:self.rac_willDeallocSignal];
    self.logOutCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Log out?" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[DRApiClient sharedClient] logout];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [DRSharedAppDelegate.navigationControllerStack.topNavigationController presentViewController:alert animated:YES completion:nil];
        return [RACSignal empty];
    }];

    @weakify(self)
    self.userHeaderViewModel = [[DRUserHeaderViewModel alloc] initWithUser:self.user];
    self.userHeaderViewModel.checkFollowCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [[[DRApiClient sharedClient] checkFollowingWithUser:self.userId] takeUntil:self.rac_willDeallocSignal];
    }];
    self.userHeaderViewModel.followCommand = [[RACCommand alloc] initWithEnabled:[isLoadSelfSignal not] signalBlock:^RACSignal *(RACTuple *tuple) {
        @strongify(self)
        RACTupleUnpack(NSNumber *isAuth, NSNumber *userId, NSNumber *isFollow) = tuple;
        if (isAuth.boolValue) {
            return isFollow.boolValue ? [[[DRApiClient sharedClient] followUserWith:userId] takeUntil:self.rac_willDeallocSignal] :
                    [[[DRApiClient sharedClient] unFollowUserWith:userId] takeUntil:self.rac_willDeallocSignal];
        } else {
            DRLoginViewModel *viewModel = [[DRLoginViewModel alloc] initWithService:self.services andParams:nil];
            [self.services presentViewModel:viewModel animated:YES completion:nil];
            @weakify(viewModel)
            return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                @strongify(viewModel)
                @weakify(subscriber)
                [viewModel.cancelCommand.executionSignals.switchToLatest.deliverOnMainThread subscribeNext:^(id x) {
                    @strongify(subscriber)
                    [subscriber sendError:nil];
                }];

                [viewModel.authSuccessSignal subscribeNext:^(NSNumber *isAuth) {
                    @strongify(subscriber)
                    if (isAuth.boolValue) {
                        [subscriber sendNext:@"auth"];
                    }
                    [subscriber sendCompleted];
                }];

                [viewModel.authCommand.errors subscribeNext:^(NSError *error) {
                    @strongify(subscriber)
                    [subscriber sendError:error];
                }];

                return (RACDisposable *) nil;
            }];
        }
    }];
    [self.userHeaderViewModel.followCommand.errors subscribe:self.errors];
    self.userHeaderViewModel.webCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *link) {
        @strongify(self)
        DRWebViewModel *viewModel = [[DRWebViewModel alloc] initWithService:self.services andParams:@{@"urlString": link}];
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];
    self.userHeaderViewModel.followerCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        DRUserListViewModel *viewModel = [[DRUserListViewModel alloc] initWithService:self.services andParams:nil];
        viewModel.userId = self.userId;
        viewModel.userListOption = DRUserListOption_Follower;
        viewModel.title = @"Follower";
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];
    self.userHeaderViewModel.followingCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        DRUserListViewModel *viewModel = [[DRUserListViewModel alloc] initWithService:self.services andParams:nil];
        viewModel.userId = self.userId;
        viewModel.userListOption = DRUserListOption_Following;
        viewModel.title = @"Following";
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];
    self.userHeaderViewModel.likeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        DRShotViewModel *viewModel = [[DRShotViewModel alloc] initWithService:self.services andParams:nil];
        viewModel.shotOption = DRShotOption_loadUserLike;
        viewModel.userForUserLike = self.user;
        viewModel.title = @"Likes";
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];
}

- (void)bindShots {
    @weakify(self)
    [self.requestRemoteDataCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self)
        if ([x isKindOfClass:[DRUser class]]) {
            self.user = x;
            self.userHeaderViewModel.user = x;
        } else {
            self.shots = x;
            self.shouldInfiniteScrolling = self.shots.count >= kDefaultShotsPerPageNumber;
            if (self.page == 1 && self.shots.count > 0) {
                self.userHeaderViewModel.showShotUrl = ((DRShot *) self.shots[0]).images.normal;
            }
        }
    }];
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSInteger)page {
    RACSignal *shotSignal;
    RACSignal *userSignal;

    if ([DRApiClient sharedClient].isUserAuthorized && self.isLoadMySelf) {
        shotSignal = [[DRApiClient sharedClient] loadMyShotsWithParams:@{kDRParamPage: @(page), kDRParamPerPage: @(kDefaultShotsPerPageNumber)}];
        userSignal = [[DRApiClient sharedClient] loadUserInfo];
    } else {
        shotSignal = [[DRApiClient sharedClient] loadShotsWithUser:self.userId params:@{kDRParamPage: @(page), kDRParamPerPage: @(kDefaultShotsPerPageNumber)}];
        userSignal = (self.firstIn && self.user != nil) ? [RACSignal empty] : [[DRApiClient sharedClient] loadAccountWithUser:self.userId];
        self.firstIn = NO;
    }

    id (^responseObject)(DRApiResponse *) = ^(DRApiResponse *apiResponse) {
        return apiResponse.object;
    };

    shotSignal = [shotSignal map:responseObject];
    userSignal = [userSignal map:responseObject];
    if (self.isLoadMySelf) {
        [userSignal subscribeNext:^(DRUser *user) {
            [DRRouter sharedInstance].user = user;
        }];
    }
    return [[RACSignal merge:@[shotSignal, userSignal]] takeUntil:self.rac_willDeallocSignal];
}

#pragma mark setter

- (void)setUser:(DRUser *)user {
    _user = user;
    if (_user) {
        self.userId = _user.userId;
    }
}

@end
