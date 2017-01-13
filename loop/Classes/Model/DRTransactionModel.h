//
//  DRTransactionModel.h
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRObject.h"
#import "DRUser.h"
#import "DRTeam.h"
#import "DRShot.h"

@interface DRTransactionModel : DRObject

@property(strong, nonatomic) NSString *created_at;
@property(strong, nonatomic) NSNumber *transactionId;
@property(strong, nonatomic) DRUser *follower;
@property(strong, nonatomic) DRUser *followee;
@property(strong, nonatomic) DRUser *user;
@property(strong, nonatomic) DRTeam *team;
@property(strong, nonatomic) DRShot *shot;

@end
