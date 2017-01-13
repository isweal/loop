//
//  DRArtWork.m
//  loop
//
//  Created by doom on 16/6/30.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRArtWork.h"
#import "NSDate+TimeAgo.h"

@implementation DRArtWork

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    NSDate *date = [formatter dateFromString:self.created_at];
    self.createdTime = [date timeAgo];
    return YES;
}

@end
