//
//  DRImage.m
//  loop
//
//  Created by doom on 16/6/30.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRImage.h"

@implementation DRImage

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.show = self.hidpi.length > 0 ? self.hidpi : self.normal;
    return YES;
}

@end
