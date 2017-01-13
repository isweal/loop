//
//  DRUser.h
//  loop
//
//  Created by doom on 16/6/27.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRAuthority.h"

@interface DRUser : DRAuthority

@property(nonatomic, strong) NSNumber *userId;
@property(nonatomic, strong) NSNumber *teams_count;
@property(nonatomic, strong) NSString *teams_url;

@end
