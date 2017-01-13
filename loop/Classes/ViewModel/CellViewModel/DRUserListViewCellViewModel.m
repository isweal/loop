//
//  DRUserListViewCellViewModel.m
//  loop
//
//  Created by doom on 2016/11/21.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRUserListViewCellViewModel.h"

@implementation DRUserListViewCellViewModel

- (instancetype)initWithUser:(DRUser *)user {
    self = [super init];
    if (self) {
        self.user = user;
    }
    return self;
}


@end
