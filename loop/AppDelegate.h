//
//  AppDelegate.h
//  loop
//
//  Created by doom on 16/6/24.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRNavigationControllerStack.h"
#import "DRViewModelServicesImpl.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong, readonly) DRViewModelServicesImpl *services;
@property(nonatomic, strong, readonly) DRNavigationControllerStack *navigationControllerStack;

-(void)setupMainView;

@end

