//
//  DRRouter.h
//  loop
//
//  Created by doom on 16/8/1.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRViewController, DRViewModel, MMDrawerController;
@class DRUser;

@interface DRRouter : NSObject

@property(nonatomic, strong) MMDrawerController *drawerController;
@property(nonatomic, strong, getter=currentUser) DRUser *user;

/// Retrieves the shared router instance.
///
/// Returns the shared router instance.
+ (instancetype)sharedInstance;


/// Retrieves the view corresponding to the given view model.
///
/// viewModel - The view model
///
/// Returns the view corresponding to the given view model.
- (DRViewController *)viewControllerForViewModel:(DRViewModel *)viewModel;

@end
