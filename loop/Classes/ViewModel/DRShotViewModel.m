//
//  DRShotViewModel.m
//  loop
//
//  Created by doom on 2016/11/22.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShotViewModel.h"
#import "DRShotCollectionViewCellViewModel.h"
#import "DRShotDetailViewModel.h"

#import "DRShot.h"

#import "DRApiClient.h"
#import "DRApiResponse.h"

@implementation DRShotViewModel

- (void)initCommand {
    [super initCommand];
    self.shouldPullToRefresh = YES;
    self.shouldInfiniteScrolling = YES;

    @weakify(self)
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
        @strongify(self)
        RACTupleUnpack(NSIndexPath *indexPath, UIImage *image) = tuple;
        DRShotCollectionViewCellViewModel *cellViewModel = self.dataSource[indexPath.row];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        TrueAssign_EXEC(param[@"shot"], cellViewModel.shot)
        TrueAssign_EXEC(param[@"shotImage"], image)
        DRShotDetailViewModel *viewModel = [[DRShotDetailViewModel alloc] initWithService:self.services
                                                                                andParams:param.copy];
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];

    [self bindShots];
}

- (void)bindShots {
    @weakify(self)
    RAC(self, shots) = [[[self.requestRemoteDataCommand.executionSignals switchToLatest]
            startWith:self.fetchLocalData]
            map:^id(NSArray *shots) {
                @strongify(self)
                self.shouldInfiniteScrolling = shots.count >= kDefaultShotsPerPageNumber;
                return shots;
            }];
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSInteger)page {
    RACSignal *signal = [RACSignal empty];
    switch (self.shotOption) {
        case DRShotOption_loadUserLike:
            NSAssert((self.userForUserLike != nil), @"userForUserLike must not be nil.");
            signal = [[DRApiClient sharedClient] loadLikesWithUser:self.userForUserLike.userId params:@{kDRParamPage: @(page), kDRParamPerPage: @(kDefaultShotsPerPageNumber)}];
    }
    return [signal map:^id(DRApiResponse *apiResponse) {
        return apiResponse.object;
    }];;
}

@end
