//
//  DRUserListViewModel.m
//  loop
//
//  Created by doom on 2016/11/21.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRUserListViewModel.h"
#import "DRUserListViewCellViewModel.h"
#import "DRUserViewModel.h"

#import "DRUser.h"
#import "DRApiClient.h"
#import "DRApiResponse.h"

@implementation DRUserListViewModel

- (void)initCommand {
    [super initCommand];
    self.shouldInfiniteScrolling = YES;
    self.shouldPullToRefresh = YES;

    @weakify(self)
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSIndexPath *indexPath) {
        @strongify(self)
        DRUserListViewCellViewModel *cellViewModel = self.dataSource[indexPath.row];
        DRUserViewModel *viewModel = [[DRUserViewModel alloc] initWithService:self.services
                                                                    andParams:@{@"user": cellViewModel.user}];
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];

    RAC(self, users) = [[self.requestRemoteDataCommand.executionSignals.switchToLatest
            startWith:self.fetchLocalData]
            map:^id(NSArray *users) {
                @strongify(self)
                self.shouldInfiniteScrolling = users.count >= kDefaultUsersPerPageNumber;
                return users;
            }];
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSInteger)page {
    RACSignal *signal = [RACSignal empty];
    switch (self.userListOption) {
        case DRUserListOption_Follower:
            signal = [[DRApiClient sharedClient] loadFollowersWithUser:self.userId
                                                                params:@{kDRParamPage: @(page), kDRParamPerPage: @(kDefaultUsersPerPageNumber)}];
            break;
        case DRUserListOption_Following:
            signal = [[DRApiClient sharedClient] loadFolloweesWithUser:self.userId
                                                                params:@{kDRParamPage: @(page), kDRParamPerPage: @(kDefaultShotsPerPageNumber)}];
            break;
        case DRUserListOption_ShotLikes:
            signal = [[DRApiClient sharedClient] loadLikesWithShot:self.shotId
                                                            params:@{kDRParamPage: @(page), kDRParamPerPage: @(kDefaultShotsPerPageNumber)}];
    }
    return [signal map:^id(DRApiResponse *apiResponse) {
        return apiResponse.object;
    }];;
}


@end
