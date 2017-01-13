//
//  DRComment.m
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRComment.h"
#import "NSDate+TimeAgo.h"

@implementation DRComment

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"commentId": @"id"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    NSDate *date = [formatter dateFromString:self.created_at];
    self.createdTime = [date timeAgo];
    return YES;
}

- (void)setBody:(NSString *)body {
    _body = body;
    _bodyMedia = [[DRHtmlMedia alloc] initWithString:body];
}

@end
