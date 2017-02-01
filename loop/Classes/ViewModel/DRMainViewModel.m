//
//  DRMainViewModel.m
//  loop
//
//  Created by doom on 16/7/12.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRMainViewModel.h"
#import "DRShotDetailViewModel.h"
#import "DRUserViewModel.h"
#import "DRLoginViewModel.h"

#import "DRShot.h"
#import "DRShotCategory.h"
#import "DRShotCategoryTimeFrame.h"

#import "DRApiClient.h"
#import "DRApiResponse.h"
#import "NSObject+ResponseCache.h"

static NSString *const kShotsCacheKey = @"shotsCache";

@interface DRMainViewModel ()

@property(nonatomic, strong) RACSignal *requestSignal;

@end

@implementation DRMainViewModel

- (void)initCommand {
    [super initCommand];
    self.category = [DRShotCategory categoryWithType:DRShotCategoryPopular];
    self.timeFrame = [DRShotCategoryTimeFrame categoryWithType:DRShotCategoryTimeFrameNow];

    self.requestRemoteDataCommand.allowsConcurrentExecution = YES;

    @weakify(self)
    RAC(self, title) = [RACObserve(self, category) map:^id(DRShotCategory *category) {
        return category.categoryName;
    }];

    [[RACObserve(self, category) skip:1] subscribeNext:^(id x) {
        @strongify(self)
        [self.requestRemoteDataCommand execute:@1];
    }];

    [[RACObserve(self, timeFrame) skip:1] subscribeNext:^(id x) {
        @strongify(self)
        [self.requestRemoteDataCommand execute:@1];
    }];

    self.testCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal empty];
    }];

    self.userCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        if ([DRApiClient sharedClient].isUserAuthorized) {
            DRUserViewModel *viewModel = [[DRUserViewModel alloc] initWithService:self.services andParams:@{@"isLoadMySelf": @"Yes"}];
            [self.services pushViewModel:viewModel animated:YES];
            return [RACSignal empty];
        } else {
            DRLoginViewModel *viewModel = [[DRLoginViewModel alloc] initWithService:self.services andParams:nil];
            [self.services presentViewModel:viewModel animated:YES completion:nil];
            @weakify(viewModel)
            return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                @strongify(viewModel)
                [viewModel.cancelCommand.executionSignals.switchToLatest.deliverOnMainThread subscribeNext:^(id x) {
                    [subscriber sendError:nil];
                }];

                [viewModel.authSuccessSignal subscribeNext:^(NSNumber *isAuth) {
                    if (isAuth.boolValue) {
                        [subscriber sendNext:@"auth"];
                    }
                    [subscriber sendCompleted];
                }];

                [viewModel.authCommand.errors subscribeNext:^(NSError *error) {
                    [subscriber sendError:error];
                }];
                return (RACDisposable *) nil;
            }];
        }
    }];
}

- (id)fetchLocalData {
    NSArray *shots = [NSObject loadKeyedArchiverResponseWithPath:kShotsCacheKey];
    return shots ?: nil;
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSInteger)page {
    if (_requestSignal) {
        [_requestSignal subscribeCompleted:^{

        }];
    }
    @weakify(self)
    _requestSignal = [[[DRApiClient sharedClient] loadShotsFromCategory:self.category timeFrame:self.timeFrame atPage:page] map:^id(DRApiResponse *apiResponse) {
        @strongify(self)
        if (page == 1 && self.category.categoryType == DRShotCategoryPopular && self.timeFrame.categoryType == DRShotCategoryTimeFrameNow) {
            [NSObject saveKeyedArchiverResponseData:apiResponse.object toPath:kShotsCacheKey];
        }
        return apiResponse.object;
    }];
    return _requestSignal;
}


@end
