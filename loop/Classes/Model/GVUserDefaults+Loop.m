//
//  GVUserDefaults+Loop.m
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

@implementation GVUserDefaults (Loop)

@dynamic currentUser, isShowIntroduction;

- (void)removeLoop {
    self.currentUser = nil;
}

@end
