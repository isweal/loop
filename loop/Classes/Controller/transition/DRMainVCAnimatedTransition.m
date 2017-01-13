//
//  DRMainVCAnimatedTransition.m
//  loop
//
//  Created by doom on 2016/10/3.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRMainVCAnimatedTransition.h"
#import "DRViewController.h"

#import "DRShotDetailViewController.h"

@interface DRMainVCAnimatedTransition ()

@property(nonatomic, strong) UIImageView *imageView;

@end

@implementation DRMainVCAnimatedTransition

- (instancetype)initWithImage:(UIImage *)image andRect:(CGRect)rect{
    self = [super init];
    if (self) {
        self.image = image;
        self.rect = rect;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    DRViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    DRViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    BOOL isPush = ([toVc.navigationController.viewControllers indexOfObject:toVc] >
            [fromVc.navigationController.viewControllers indexOfObject:fromVc]);
    if (isPush) {
        fromVc.view.hidden = YES;
        toVc.view.alpha = 0;
        CGRect frame = [transitionContext finalFrameForViewController:toVc];
        toVc.view.frame = frame;
        self.imageView.frame = CGRectOffset(self.rect, 0, 64);
        [transitionContext.containerView addSubview:toVc.view];
        [transitionContext.containerView addSubview:self.imageView];
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.imageView.frame = CGRectMake(frame.origin.x, frame.origin.y, kScreen_Width, kScreenWidth * 3 / 4);
            toVc.view.alpha = 1;
        } completion:^(BOOL finished) {
            [self.imageView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    } else{
        CGRect frame = ((DRShotDetailViewController *)fromVc).selectImageConvertFrame;
        self.imageView.frame = CGRectMake(frame.origin.x, frame.origin.y + 64, kScreen_Width, kScreenWidth * 3 / 4);
        toVc.view.hidden = YES;
        [transitionContext.containerView addSubview:toVc.snapShot];
        [transitionContext.containerView addSubview:toVc.view];
        [transitionContext.containerView addSubview:self.imageView];
        [transitionContext.containerView sendSubviewToBack:toVc.snapShot];
        toVc.snapShot.alpha = 0.5;
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             fromVc.view.alpha = 0;
                             toVc.snapShot.alpha = 1;
                             self.imageView.frame = CGRectOffset(self.rect, 0, 64);
                         }
                         completion:^(BOOL finished) {
                             toVc.view.hidden = NO;
                             [toVc.snapShot removeFromSuperview];
                             [self.imageView removeFromSuperview];
                             if (![transitionContext transitionWasCancelled]) {
                                 toVc.snapShot = nil;
                             }
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:self.image];
    }
    return _imageView;
}


@end
