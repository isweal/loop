//
//  DRUser.m
//  loop
//
//  Created by doom on 16/6/27.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRUser.h"

@implementation DRUser

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userId" : @"id"};
}

@end