//
//  DRCollectionViewModel.h
//  loop
//
//  Created by doom on 16/8/12.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRViewModel.h"

@interface DRCollectionViewModel : DRViewModel

@property(nonatomic, copy) NSArray *dataSource;

@property(nonatomic, assign) NSInteger page;

@property(nonatomic, assign) BOOL shouldPullToRefresh;
@property(nonatomic, assign) BOOL shouldInfiniteScrolling;

@property(nonatomic, strong) RACCommand *didSelectCommand;
@property(nonatomic, strong, readonly) RACCommand *requestRemoteDataCommand;

- (id)fetchLocalData;

- (BOOL (^)(NSError *error))requestRemoteDataErrorsFilter;

- (RACSignal *)requestRemoteDataSignalWithPage:(NSInteger)page;

@end
