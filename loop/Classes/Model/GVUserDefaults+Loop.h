//
//  GVUserDefaults+Loop.h
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <GVUserDefaults/GVUserDefaults.h>

@interface GVUserDefaults (Loop)

@property(nonatomic, weak) NSDictionary *currentUser;
@property(nonatomic, assign) BOOL isShowIntroduction;

- (void)removeLoop;

@end
