//
//  UIView+common.h
//  loop
//
//  Created by doom on 2017/1/6.
//  Copyright © 2017年 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Common)

// add lineView
- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown;

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color;

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace;

+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve;

@end
