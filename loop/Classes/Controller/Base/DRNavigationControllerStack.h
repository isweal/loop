//
//  DRNavigationControllerStack.h
//  loop
//
//  Created by doom on 16/8/1.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRViewModelServices.h"

@interface DRNavigationControllerStack : NSObject

/// Initialization method. This is the preferred way to create a new navigation controller stack.
///
/// services - The service bus of the `Model` layer.
///
/// Returns a new navigation controller stack.
- (instancetype)initWithServices:(id <DRViewModelServices>)services;

/// Pushes the navigation controller.
///
/// navigationController - the navigation controller
- (void)pushNavigationController:(UINavigationController *)navigationController;

/// Pops the top navigation controller in the stack.
///
/// Returns the popped navigation controller.
- (UINavigationController *)popNavigationController;

/// Retrieves the top navigation controller in the stack.
///
/// Returns the top navigation controller in the stack.
- (UINavigationController *)topNavigationController;

@end
