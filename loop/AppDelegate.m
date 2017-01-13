//
//  AppDelegate.m
//  loop
//
//  Created by doom on 16/6/24.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "AppDelegate.h"
#import "DRMainViewController.h"
#import "DRNodeRightViewController.h"
#import "MMDrawerController.h"
#import "DRNavigationController.h"

#import "DRMainViewModel.h"

#import "DRRouter.h"

#import "JDStatusBarNotification.h"

@interface AppDelegate ()

@property(nonatomic, strong, readwrite) DRViewModelServicesImpl *services;
@property(nonatomic, strong, readwrite) DRNavigationControllerStack *navigationControllerStack;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    self.services = [[DRViewModelServicesImpl alloc] init];
    self.navigationControllerStack = [[DRNavigationControllerStack alloc] initWithServices:self.services];
    [self customizeInterface];
    [self setupMainView];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)customizeInterface {
    //设置Nav的背景色和title色
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0x333333"]] forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTintColor:[UIColor whiteColor]];//返回按钮的箭头颜色
    NSDictionary *textAttributes = @{
            NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
            NSForegroundColorAttributeName: [UIColor whiteColor],
    };
    [navigationBarAppearance setTitleTextAttributes:textAttributes];

    [[UITextField appearance] setTintColor:[UIColor colorWithHexString:@"0x3bbc79"]];//设置UITextField的光标颜色
    [[UITextView appearance] setTintColor:[UIColor colorWithHexString:@"0x3bbc79"]];//设置UITextView的光标颜色
    [JDStatusBarNotification setDefaultStyle:^JDStatusBarStyle *(JDStatusBarStyle *style) {
//        // main properties
//        style.barColor = <#color#>;
//        style.textColor = <#color#>;
//        style.font = <#font#>;
//
//        // advanced properties
//        style.animationType = <#type#>;
//        style.textShadow = <#shadow#>;
//        style.textVerticalPositionAdjustment = <#adjustment#>;
//
//        // progress bar
//        style.progressBarColor = <#color#>;
//        style.progressBarHeight = <#height#>;
//        style.progressBarPosition = <#position#>;

        return style;
    }];
}

- (void)setupMainView {
    DRMainViewController *mainViewController = [[DRMainViewController alloc] initWithViewModel:[[DRMainViewModel alloc] initWithService:self.services andParams:nil]];
    DRNavigationController *mainNav = [[DRNavigationController alloc] initWithRootViewController:mainViewController];
    DRNodeRightViewController *nodeRightViewController = [[DRNodeRightViewController alloc] init];

    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainNav
                                                                           leftDrawerViewController:nil
                                                                          rightDrawerViewController:nodeRightViewController];
    drawerController.view.backgroundColor = [UIColor whiteColor];
    drawerController.maximumLeftDrawerWidth = 230;
    drawerController.maximumRightDrawerWidth = 120;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;

    [DRRouter sharedInstance].drawerController = drawerController;

    [self.navigationControllerStack pushNavigationController:mainNav];

    [self.window setRootViewController:drawerController];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
