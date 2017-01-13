//
// Created by doom on 16/9/18.
// Copyright (c) 2016 DOOM. All rights reserved.
//

#import "NSDate+TimeAgo.h"


@implementation NSDate (TimeAgo)

- (NSString *)timeAgo {
    NSTimeInterval timeInterval = [self timeIntervalSinceNow];
    timeInterval = -timeInterval;
    //标准时间和北京时间差8个小时
    timeInterval = timeInterval - 8 * 60 * 60;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"just"];
    } else if ((temp = (long) (timeInterval / 60)) < 60) {
        result = [NSString stringWithFormat:@"%ld m", temp];
    } else if ((temp = temp / 60) < 24) {
        result = [NSString stringWithFormat:@"%ld h", temp];
    } else if ((temp = temp / 24) < 30) {
        result = [NSString stringWithFormat:@"%ld d", temp];
    } else if ((temp = temp / 30) < 12) {
        result = [NSString stringWithFormat:@"%ld m", temp];
    } else {
        temp = temp / 12;
        result = [NSString stringWithFormat:@"%ld y", temp];
    }

    return result;
}


@end