//
//  DRUserHeaderViewModel.h
//  loop
//
//  Created by doom on 2016/10/20.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRUserHeaderViewModel : NSObject

@property(nonatomic, strong) RACSignal *reuse;

@property(nonatomic, strong) DRUser *user;
@property(nonatomic, strong) NSString *showShotUrl;
@property(nonatomic, assign) CGFloat contentOffsetY;
@property(nonatomic, assign) BOOL isFollow;

@property(nonatomic, strong) RACCommand *checkFollowCommand;
@property(nonatomic, strong) RACCommand *followCommand;
@property(nonatomic, strong) RACCommand *webCommand;
@property(nonatomic, strong) RACCommand *followerCommand;
@property(nonatomic, strong) RACCommand *followingCommand;
@property(nonatomic, strong) RACCommand *shotCommand;
@property(nonatomic, strong) RACCommand *likeCommand;

- (instancetype)initWithUser:(DRUser *)user;

@end
