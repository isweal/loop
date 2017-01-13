//
// Created by doom on 16/7/12.
// Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRShotCollectionViewCellViewModel.h"
#import "DRShot.h"


@implementation DRShotCollectionViewCellViewModel

- (instancetype)initWithShot:(DRShot *)shot {
    self = [super init];
    if(self){
        self.shot = shot;
    }
    return self;
}


@end