//
//  DSCountDownUtil.h
//  loop
//
//  Created by doom on 2016/9/21.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CountChanging)(NSInteger second);

typedef void (^CountComplete)(NSInteger second);

@interface DSCountDownUtil : NSObject

+ (void)startWithSecond:(NSInteger)second changing:(CountChanging)countChanging complete:(CountComplete)countComplete;

@end
