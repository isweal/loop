//
//  DRArtWork.h
//  loop
//
//  Created by doom on 16/6/30.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRObject.h"
#import "DRUser.h"
#import "DRTeam.h"


@interface DRArtWork : DRObject

@property(copy, nonatomic) NSString *created_at;
@property(copy, nonatomic) NSString *createdTime;

@property(copy, nonatomic) NSString *updated_at;
@property(copy, nonatomic) NSString *updatedTime;

@property(strong, nonatomic) DRUser *user;
@property(strong, nonatomic) DRTeam *team;

@end
