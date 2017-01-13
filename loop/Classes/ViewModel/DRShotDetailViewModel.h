//
//  DRShotDetailViewModel.h
//  loop
//
//  Created by doom on 16/8/16.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRTableViewModel.h"

@class DRShot;
@class DRShotDetailHeaderViewModel;

@interface DRShotDetailViewModel : DRTableViewModel

@property(nonatomic, strong) DRShot *shot;
@property(nonatomic, strong) NSNumber *shotId;
@property(nonatomic, strong) NSArray *comments;

@property(nonatomic, strong) RACCommand *didClickUrlCommand;
@property(nonatomic, strong) RACCommand *uploadCommentCommand;
@property(nonatomic, strong) RACCommand *updateCommentCommand;

@property(nonatomic, strong) DRShotDetailHeaderViewModel *shotDetailHeaderViewModel;

@end
