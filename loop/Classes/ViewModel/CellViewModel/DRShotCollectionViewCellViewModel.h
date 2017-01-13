//
// Created by doom on 16/7/12.
// Copyright (c) 2016 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRShot;

@interface DRShotCollectionViewCellViewModel : NSObject

@property(nonatomic, strong) DRShot *shot;

- (instancetype)initWithShot:(DRShot *)shot;

@end
