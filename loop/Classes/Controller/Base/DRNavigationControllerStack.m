//
//  DRNavigationControllerStack.m
//  loop
//
//  Created by doom on 16/8/1.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRNavigationControllerStack.h"
#import "DRNavigationController.h"
#import "DRMainVCAnimatedTransition.h"

#import "DRViewController.h"
#import "DRShotViewController.h"
#import "DRShotDetailViewController.h"

@interface DRNavigationControllerStack () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) id <DRViewModelServices> services;
@property(nonatomic, strong) NSMutableArray *navigationControllers;

@property(nonatomic, strong, readwrite) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@end;

@implementation DRNavigationControllerStack

- (instancetype)initWithServices:(id <DRViewModelServices>)services {
    self = [super init];
    if (self) {
        self.services = services;
        self.navigationControllers = [NSMutableArray array];
        [self registerNavigationHook];
    }
    return self;
}

- (void)pushNavigationController:(UINavigationController *)navigationController {
    if ([self.navigationControllers containsObject:navigationController]) return;
    navigationController.delegate = self;
    navigationController.interactivePopGestureRecognizer.delegate = self;
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [navigationController.view addGestureRecognizer:popRecognizer];
    popRecognizer.delegate = self;
    [self.navigationControllers addObject:navigationController];
}

- (UINavigationController *)popNavigationController {
    UINavigationController *navigationController = self.navigationControllers.lastObject;
    [self.navigationControllers removeLastObject];
    return navigationController;
}

- (UINavigationController *)topNavigationController {
    return self.navigationControllers.lastObject;
}

- (void)registerNavigationHook {
    @weakify(self)
    [[(NSObject *) self.services rac_signalForSelector:@selector(pushViewModel:animated:)]
            subscribeNext:^(RACTuple *tuple) {
                @strongify(self)
                DRViewController *topViewController = (DRViewController *) [self.navigationControllers.lastObject topViewController];
                topViewController.snapShot = [[self.navigationControllers.lastObject view] snapshotViewAfterScreenUpdates:NO];
                UIViewController *viewController = [[DRRouter sharedInstance] viewControllerForViewModel:tuple.first];
//                奇怪的问题，设置为YES，进入SVWebViewController，再返回到rootViewController也就是DRMainViewController后
//                居然还保留的有下面的toolBar。。。
//                viewController.hidesBottomBarWhenPushed = YES;
                [self.navigationControllers.lastObject pushViewController:viewController animated:YES];
            }];
    [[(NSObject *) self.services rac_signalForSelector:@selector(popViewModelAnimated:)]
            subscribeNext:^(RACTuple *tuple) {
                @strongify(self)
                [self.navigationControllers.lastObject popViewControllerAnimated:[tuple.first boolValue]];
            }];
    [[(NSObject *) self.services rac_signalForSelector:@selector(popToRootViewModelAnimated:)]
            subscribeNext:^(RACTuple *tuple) {
                @strongify(self)
                [self.navigationControllers.lastObject popToRootViewControllerAnimated:[tuple.first boolValue]];
            }];
    [[(NSObject *) self.services rac_signalForSelector:@selector(presentViewModel:animated:completion:)]
            subscribeNext:^(RACTuple *tuple) {
                @strongify(self)
                UIViewController *viewController = [DRRouter.sharedInstance viewControllerForViewModel:tuple.first];

                UINavigationController *presentingViewController = self.navigationControllers.lastObject;
                DRNavigationController *nav = [[DRNavigationController alloc] initWithRootViewController:viewController];
                [self pushNavigationController:nav];
                [presentingViewController presentViewController:nav animated:[tuple.second boolValue] completion:tuple.third];
            }];
    [[(NSObject *) self.services rac_signalForSelector:@selector(dismissViewModelAnimated:completion:)]
            subscribeNext:^(RACTuple *tuple) {
                @strongify(self)
                [[self popNavigationController] dismissViewControllerAnimated:[tuple.first boolValue] completion:tuple.second];
            }];
    [[(NSObject *) self.services rac_signalForSelector:@selector(resetRootViewModel:)]
            subscribeNext:^(RACTuple *tuple) {
                @strongify(self)
                [self.navigationControllers removeAllObjects];
                UIViewController *viewController = [DRRouter.sharedInstance viewControllerForViewModel:tuple.first];
                DRNavigationController *nav = [[DRNavigationController alloc] initWithRootViewController:viewController];
                [self pushNavigationController:nav];
                [UIApplication sharedApplication].delegate.window.rootViewController = nav;
            }];
}

#pragma mark UIPanGesture

- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:recognizer.view].x / CGRectGetWidth(recognizer.view.frame);
    progress = (CGFloat) MIN(1.0, MAX(0.0, progress));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [[self topNavigationController] popViewControllerAnimated:YES];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self.interactivePopTransition updateInteractiveTransition:progress];
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (progress > 0.25) {
            [self.interactivePopTransition finishInteractiveTransition];
        } else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }

        self.interactivePopTransition = nil;
    }
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer {
    UINavigationController *nav = [self topNavigationController];
    if ([nav.transitionCoordinator isAnimated])
        return NO;

    if (nav.viewControllers.count < 2)
        return NO;

    UIViewController *fromVC = nav.viewControllers[nav.viewControllers.count - 1];
    UIViewController *toVC = nav.viewControllers[nav.viewControllers.count - 2];

    if ([fromVC isKindOfClass:[DRShotDetailViewController class]] && [toVC isKindOfClass:[DRShotViewController class]]) {
        return YES;
    } else if (recognizer == nav.interactivePopGestureRecognizer) {
        return YES;
    }
    return NO;
}

#pragma mark UINavigationControllerDelegate

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    return self.interactivePopTransition;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    switch (operation){
        case UINavigationControllerOperationPush:
            if ([fromVC isKindOfClass:[DRShotViewController class]] && [toVC isKindOfClass:[DRShotDetailViewController class]]) {
                DRShotViewController *vc = (DRShotViewController *) fromVC;
                return [[DRMainVCAnimatedTransition alloc] initWithImage:vc.selectImage andRect:vc.selectImageConvertFrame];
            }
            break;
        case UINavigationControllerOperationPop:
            if ([fromVC isKindOfClass:[DRShotDetailViewController class]] && [toVC isKindOfClass:[DRShotViewController class]]) {
                DRShotViewController *vc = (DRShotViewController *) toVC;
                return [[DRMainVCAnimatedTransition alloc] initWithImage:vc.selectImage andRect:vc.selectImageConvertFrame];
            }
            break;
        default:
            break;
    }
    return nil;
}

@end
