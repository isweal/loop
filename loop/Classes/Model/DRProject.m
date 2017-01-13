//
//  DRProject.m
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRProject.h"

@implementation DRProject

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"projectId" : @"id",
            @"projectDescription" : @"description"};
}

@end
