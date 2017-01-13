//
//  DRTransactionModel.m
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRTransactionModel.h"
#import "DRUser.h"
#import "DRTeam.h"
#import "DRShot.h"

@implementation DRTransactionModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"transactionId": @"id"};
}

- (void)setFollowee:(DRUser *)followee {
    _followee = followee;
    _user = followee;
}

- (void)setFollower:(DRUser *)follower {
    _follower = follower;
    _user = follower;
}

@end
