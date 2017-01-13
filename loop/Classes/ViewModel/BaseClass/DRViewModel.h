//
//  DRViewModel.h
//  loop
//
//  Created by doom on 16/7/12.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DRViewModelServices;

@interface DRViewModel : NSObject

- (instancetype)initWithService:(id <DRViewModelServices>)services andParams:(NSDictionary *)params;

@property(nonatomic, strong, readonly) id <DRViewModelServices> services;

@property(nonatomic, copy, readonly) NSDictionary *params;

@property(nonatomic, strong, readonly) RACSubject *errors;

@property(nonatomic, copy) NSString *title;

@property(nonatomic, assign) BOOL shouldFetchLocalDataOnViewModelInitialize;
@property(nonatomic, assign) BOOL shouldRequestRemoteDataOnViewDidLoad;
@property(nonatomic, assign) BOOL firstIn;

@property(nonatomic, strong, readonly) RACSubject *willDisappearSignal;

- (void)initCommand;

@end
