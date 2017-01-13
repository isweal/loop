//
// Created by doom on 2016/9/23.
// Copyright (c) 2016 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BerButtonStyle) {
    BerButtonStyle_BlueLogin = 0,
    BerButtonStyle_GreenRegister
};

@interface UIButton (QuickBuild)

+ (UIButton *)buttonWithStyle:(BerButtonStyle)style andTitle:(NSString *)title target:(id)target action:(SEL)action;

@end