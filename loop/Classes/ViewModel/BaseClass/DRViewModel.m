//
//  DRViewModel.m
//  loop
//
//  Created by doom on 16/7/12.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRViewModel.h"
#import "DRViewModelServices.h"

@interface DRViewModel ()

@property(nonatomic, strong, readwrite) id <DRViewModelServices> services;

@property(nonatomic, copy, readwrite) NSDictionary *params;

@property(nonatomic, strong, readwrite) RACSubject *errors;

@property(nonatomic, strong, readwrite) RACSubject *willDisappearSignal;

@end

@implementation DRViewModel

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    DRViewModel *viewModel = (DRViewModel *) [super allocWithZone:zone];

    @weakify(viewModel)
    [[viewModel
            rac_signalForSelector:@selector(initWithService:andParams:)]
            subscribeNext:^(id x) {
                @strongify(viewModel)
                [viewModel initCommand];
            }];

    return viewModel;
}

- (instancetype)initWithService:(id <DRViewModelServices>)services andParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.shouldFetchLocalDataOnViewModelInitialize = YES;
        self.shouldRequestRemoteDataOnViewDidLoad = YES;
        self.firstIn = YES;
        self.services = services;
        self.params = params;
    }
    return self;
}


- (void)initCommand {

}

- (RACSubject *)willDisappearSignal {
    if (!_willDisappearSignal) {
        _willDisappearSignal = [RACSubject subject];
    }
    return _willDisappearSignal;
}

- (RACSubject *)errors {
    if (!_errors) {
        _errors = [RACSubject subject];
    }
    return _errors;
}

@end
