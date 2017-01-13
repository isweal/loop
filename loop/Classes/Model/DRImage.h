//
//  DRImage.h
//  loop
//
//  Created by doom on 16/6/30.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRObject.h"

@interface DRImage : DRObject

@property(nonatomic, copy) NSString *show;

@property(nonatomic, copy) NSString *hidpi;
@property(nonatomic, copy) NSString *normal;
@property(nonatomic, copy) NSString *teaser;

@end
