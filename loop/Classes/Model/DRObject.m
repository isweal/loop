//
//  DRObject.m
//  loop
//
//  Created by doom on 16/8/17.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRObject.h"

@implementation DRObject

- (void)encodeWithCoder:(NSCoder *)aCoder { [self modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self modelCopy]; }
- (NSUInteger)hash { return [self modelHash]; }
- (BOOL)isEqual:(id)object { return [self modelIsEqual:object]; }

@end
