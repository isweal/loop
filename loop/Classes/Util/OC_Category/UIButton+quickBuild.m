//
// Created by doom on 2016/9/23.
// Copyright (c) 2016 DOOM. All rights reserved.
//

#import "UIButton+QuickBuild.h"


@implementation UIButton (QuickBuild)

+ (UIButton *)buttonWithStyle:(BerButtonStyle)style andTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    const SEL selArray[] = {@selector(loginBlue), @selector(greenRegister)};
    if ([btn respondsToSelector:selArray[style]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [btn performSelector:selArray[style]];
#pragma clang diagnostic pop
    }
    return btn;
}

- (void)defaultStyle {
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
    [self setAdjustsImageWhenHighlighted:NO];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont systemFontOfSize:self.titleLabel.font.pointSize]];
}

- (void)loginBlue {
    [self defaultStyle];
    self.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)greenRegister {
    [self defaultStyle];
    self.layer.borderColor = [UIColor clearColor].CGColor;
}


@end