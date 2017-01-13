//
//  DRNavigationController.m
//  loop
//
//  Created by doom on 16/7/1.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRNavigationController.h"
#import "MMDrawerController.h"

@interface DRNavigationController ()

@end

@implementation DRNavigationController

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

@end
