//
//  DRShot.m
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShot.h"

@implementation DRShot

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"shotId" : @"id",
    @"shotDescription": @"description"};
}

- (void)setShotDescription:(NSString *)shotDescription {
    _shotDescription = shotDescription;
    _shotshotDescriptionMedia = [[DRHtmlMedia alloc] initWithString:shotDescription];
}

@end
