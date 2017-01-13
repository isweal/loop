//
//  DRNavigationProtocol.h
//  loop
//
//  Created by doom on 16/8/1.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRViewModel.h"

@protocol DRNavigationProtocol <NSObject>

- (void)pushViewModel:(DRViewModel *)viewModel animated:(BOOL)animated;

- (void)popViewModelAnimated:(BOOL)animated;

- (void)popToRootViewModelAnimated:(BOOL)animated;

- (void)presentViewModel:(DRViewModel *)viewModel animated:(BOOL)animated completion:(VoidBlock)completion;

- (void)dismissViewModelAnimated:(BOOL)animated completion:(VoidBlock)completion;

- (void)resetRootViewModel:(DRViewModel *)viewModel;

@end
