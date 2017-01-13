//
//  DRLoadingView.h
//  loop
//
//  Created by doom on 16/7/7.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRLoadingView : UIView

@property(nonatomic, strong) YYAnimatedImageView *animatedImageView;

- (void)performFailure:(void (^)(void))failure;

@end
