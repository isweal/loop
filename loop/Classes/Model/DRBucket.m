//
//  DRBucket.m
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRBucket.h"

@implementation DRBucket

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"bucketId" : @"id",
            @"bucketDescription" : @"description"};
}

@end
