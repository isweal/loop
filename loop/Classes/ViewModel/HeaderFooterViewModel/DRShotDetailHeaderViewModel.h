//
//  DRShotDetailHeaderViewModel.h
//  loop
//
//  Created by doom on 16/9/5.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRShot.h"

@interface DRShotDetailHeaderViewModel : NSObject

@property(nonatomic, strong) DRShot *shot;
@property(nonatomic, copy) NSAttributedString *shotDescription;

@property(nonatomic, strong) UIImage *shotImage;

@property(nonatomic, assign) BOOL isLike;

@property(nonatomic, strong) RACCommand *checkLikeCommand;
@property(nonatomic, strong) RACCommand *userCommand;
@property(nonatomic, strong) RACCommand *bucketCommand;
@property(nonatomic, strong) RACCommand *likeShotCommand;
@property(nonatomic, strong) RACCommand *likesCommand;
@property(nonatomic, strong) RACCommand *commentCommand;
@property(nonatomic, strong) RACCommand *didClickUrlCommand;

- (instancetype)initWithShot:(DRShot *)shot;

@end
