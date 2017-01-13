//
//  DRViewController.h
//  loop
//
//  Created by doom on 16/7/1.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRLoadingView, DRViewModel;

@interface DRViewController : UIViewController

@property(nonatomic, strong, readonly) DRViewModel *viewModel;
@property(nonatomic, strong) UIView *snapShot;
@property(nonatomic, strong) DRLoadingView *loadingView;

- (void)showLoadingView;

- (void)hideLoadingView;

- (instancetype)initWithViewModel:(DRViewModel *)viewModel;

-(void)bindViewModel;

@end
