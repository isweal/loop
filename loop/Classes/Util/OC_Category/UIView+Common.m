//
//  UIView+common.m
//  loop
//
//  Created by doom on 2017/1/6.
//  Copyright © 2017年 DOOM. All rights reserved.
//

static const NSInteger kLineViewTag = 9527;

#import "UIView+Common.h"

@implementation UIView (Common)

#pragma mark add lineView

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown {
    [self addLineUp:hasUp andDown:hasDown andColor:kDefaultLineColor];
}

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color {
    [self addLineUp:hasUp andDown:hasDown andColor:color andLeftSpace:0];
}

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace {
    [self removeWithTag:kLineViewTag];
    if (hasUp) {
        UIView *upView = [UIView lineViewWithPointYY:0 andColor:color andLeftSpace:leftSpace];
        upView.tag = kLineViewTag;
        [self addSubview:upView];
    }
    if (hasDown) {
        UIView *downView = [UIView lineViewWithPointYY:CGRectGetMaxY(self.bounds) - 0.5 andColor:color andLeftSpace:leftSpace];
        downView.tag = kLineViewTag;
        [self addSubview:downView];
    }
}

+ (UIView *)lineViewWithPointYY:(CGFloat)pointY andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(leftSpace, pointY, kScreen_Width - leftSpace, 0.5)];
    lineView.backgroundColor = color;
    return lineView;
}

- (void)removeWithTag:(NSInteger)tag {
    for (UIView *view in [self subviews]) {
        if (view.tag == tag) {
            [view removeFromSuperview];
        }
    }
}

+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve {
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            break;
    }

    return kNilOptions;
}


@end
