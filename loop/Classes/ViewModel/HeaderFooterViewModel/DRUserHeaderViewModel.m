//
//  DRUserHeaderViewModel.m
//  loop
//
//  Created by doom on 2016/10/20.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRUserHeaderViewModel.h"

@implementation DRUserHeaderViewModel

- (instancetype)initWithUser:(DRUser *)user {
    self = [super init];
    if(self){
        self.user = user;
    }
    return self;
}


@end
