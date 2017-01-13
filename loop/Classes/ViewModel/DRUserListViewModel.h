//
//  DRUserListViewModel.h
//  loop
//
//  Created by doom on 2016/11/21.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRTableViewModel.h"

typedef NS_ENUM(NSInteger, DRUserListOption) {
    DRUserListOption_Follower = 0,
    DRUserListOption_Following,
    DRUserListOption_ShotLikes,
};

@interface DRUserListViewModel : DRTableViewModel

@property(nonatomic, assign) DRUserListOption userListOption;

// DRUserListOption_Follower, DRUserListOption_Following
@property(nonatomic, strong) NSNumber *userId;

// DRUserListOption_Likes
@property(nonatomic, strong) NSNumber *shotId;

@property(nonatomic, strong) NSArray *users;

@end
