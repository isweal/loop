//
//  DRMainViewController.m
//  loop
//
//  Created by doom on 16/7/4.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRMainViewController.h"
#import "MMDrawerController.h"
#import "DRNodeRightViewController.h"

#import "MenuPopView.h"

#import "DRMainViewModel.h"

#import "DRShotCategory.h"
#import "DRShotCategoryTimeFrame.h"

@interface DRMainViewController ()

@property(nonatomic, strong, readonly) DRMainViewModel *viewModel;

@property(nonatomic, strong) MenuPopView *menuPopView;

@end

@implementation DRMainViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-time"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self action:@selector(showTimeLimitView)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;

    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-user"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:nil action:nil];
    leftBarButtonItem.rac_command = self.viewModel.userCommand;
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;

    @weakify(self)
    // 以后看弄不弄成单例吧
    if (self.parentViewController.parentViewController) {
        MMDrawerController *drawerController = (MMDrawerController *) self.parentViewController.parentViewController;
        @weakify(drawerController)
        if ([drawerController.rightDrawerViewController isKindOfClass:[DRNodeRightViewController class]]) {
            ((DRNodeRightViewController *) drawerController.rightDrawerViewController).selectRowAtIndex = ^(NSInteger index) {
                @strongify(self)
                @strongify(drawerController)
                [drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
                    self.viewModel.firstIn = YES;
                    self.viewModel.category = [DRShotCategory categoryWithType:(DRShotCategoryType) index];
                }];
            };
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [DRRouter sharedInstance].drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModePanningCenterView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [DRRouter sharedInstance].drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
}

- (void)bindViewModel {
    [super bindViewModel];
}

/**
 *  弹出时间筛选视图
 */
- (void)showTimeLimitView {
    [self.menuPopView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark getter

- (MenuPopView *)menuPopView {
    if (!_menuPopView) {
        _menuPopView = [[MenuPopView alloc] initWithTitles:[DRShotCategoryTimeFrame allCategoriesNames] images:nil];
        _menuPopView.startPoint = CGPointMake(self.view.width, 64);
        _menuPopView.endPoint = CGPointMake(self.view.width / 2, self.view.height / 2);
        _menuPopView.enableFitCellWidth = NO;
        _menuPopView.cellWidth = self.view.width - 40;
        [_menuPopView refreshSize];
        @weakify(self)
        _menuPopView.selectRowAtIndex = ^(NSInteger index) {
            @strongify(self)
            DRShotCategoryTimeFrame *timeFrame = [DRShotCategoryTimeFrame categoryWithType:(DRShotCategoryTimeFrameType) index];
            self.viewModel.firstIn = YES;
            self.viewModel.timeFrame = timeFrame;
        };
    }
    return _menuPopView;
}

@end
