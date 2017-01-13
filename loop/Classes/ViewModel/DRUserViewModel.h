//
//  DRUserViewModel.h
//  loop
//
//  Created by doom on 2016/10/20.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRShotViewModel.h"
#import "DRUserHeaderViewModel.h"

@interface DRUserViewModel : DRShotViewModel

@property(nonatomic, strong) NSNumber *userId;
@property(nonatomic, strong) DRUser *user; // userId or user

@property(nonatomic, assign) BOOL isLoadMySelf;

@property(nonatomic, strong) RACSignal *showLogOutItemSignal;
@property(nonatomic, strong) RACCommand *logOutCommand;

@property(nonatomic, strong) DRUserHeaderViewModel *userHeaderViewModel;

@end
