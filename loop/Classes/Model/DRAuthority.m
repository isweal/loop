//
//  DRAuthority.m
//  loop
//
//  Created by doom on 16/6/30.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRAuthority.h"

@implementation DRAuthority

- (void)setType:(NSString *)type {
    _type = type;
    _can_upload_shot = [@[@"Player", @"Team"] containsObject:type];
}

@end
