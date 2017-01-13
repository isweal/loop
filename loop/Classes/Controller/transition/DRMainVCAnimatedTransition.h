//
//  DRMainVCAnimatedTransition.h
//  loop
//
//  Created by doom on 2016/10/3.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRMainVCAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initWithImage:(UIImage *)image andRect:(CGRect)rect;

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, assign) CGRect rect;

@end
