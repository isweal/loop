//
//  DRTableViewModel.m
//  loop
//
//  Created by doom on 16/7/13.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRTableViewModel.h"

@interface DRTableViewModel ()

@property(nonatomic, strong, readwrite) RACCommand *requestRemoteDataCommand;

@end

@implementation DRTableViewModel

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
