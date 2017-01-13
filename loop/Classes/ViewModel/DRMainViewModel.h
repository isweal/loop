//
//  DRMainViewModel.h
//  loop
//
//  Created by doom on 16/7/12.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShotViewModel.h"

@class DRShotCategory, DRShotCategoryTimeFrame;

@interface DRMainViewModel : DRShotViewModel

@property(nonatomic, assign) DRShotCategory *category;
@property(nonatomic, assign) DRShotCategoryTimeFrame *timeFrame;

@property(nonatomic, strong) RACCommand *testCommand;
@property(nonatomic, strong) RACCommand *userCommand;

@end
