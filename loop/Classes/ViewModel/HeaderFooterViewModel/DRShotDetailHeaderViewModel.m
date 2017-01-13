//
//  DRShotDetailHeaderViewModel.m
//  loop
//
//  Created by doom on 16/9/5.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRShotDetailHeaderViewModel.h"

@implementation DRShotDetailHeaderViewModel

- (instancetype)initWithShot:(DRShot *)shot {
    self = [super init];
    if (self) {
        self.shot = shot;
    }
    return self;
}

- (void)setShot:(DRShot *)shot {
    _shot = shot;
    self.shotDescription = [_shot.shotshotDescriptionMedia setupHighlight];
}


@end
