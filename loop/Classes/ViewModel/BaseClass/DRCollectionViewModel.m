//
//  DRCollectionViewModel.m
//  loop
//
//  Created by doom on 16/8/12.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRCollectionViewModel.h"

@interface DRCollectionViewModel()

@property(nonatomic, strong, readwrite) RACCommand *requestRemoteDataCommand;

@end

@implementation DRCollectionViewModel

- (void)initCommand {
    [super initCommand];

    @weakify(self)
    self.requestRemoteDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSNumber *p) {
        @strongify(self)
        self.page = p.integerValue;
        return [[self requestRemoteDataSignalWithPage:self.page] takeUntil:self.rac_willDeallocSignal];
    }];

    [[self.requestRemoteDataCommand.errors filter:[self requestRemoteDataErrorsFilter]] subscribe:self.errors];
}

- (id)fetchLocalData {
    return nil;
}

- (BOOL (^)(NSError *error))requestRemoteDataErrorsFilter {
    return ^BOOL(NSError *error) {
        return YES;
    };
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSInteger)page {
    return [RACSignal empty];
}


@end