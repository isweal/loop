//
//  DRViewController.m
//  loop
//
//  Created by doom on 16/7/1.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRViewController.h"
#import "DRLoadingView.h"
#import "JDStatusBarNotification.h"

#import "DRLoginViewModel.h"

#import "DRApiClient.h"

@interface DRViewController () <UIGestureRecognizerDelegate>

@property(nonatomic, strong, readwrite) DRViewModel *viewModel;

@end

@implementation DRViewController

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    DRViewController *viewController = (DRViewController *) [super allocWithZone:zone];
    @weakify(viewController)
    [[viewController
            rac_signalForSelector:@selector(viewDidLoad)]
            subscribeNext:^(id x) {
                @strongify(viewController)
                [viewController bindViewModel];
            }];
    return viewController;
}

- (instancetype)initWithViewModel:(DRViewModel *)viewModel {
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackGroundColor;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style
                                                                            target:nil action:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.viewModel.willDisappearSignal sendNext:nil];

    if ([self isMovingFromParentViewController]) {
        self.snapShot = [self.navigationController.view snapshotViewAfterScreenUpdates:NO];
    }
}

- (void)bindViewModel {
    @weakify(self)
    RAC(self, title) = RACObserve(self.viewModel, title);
    [self.viewModel.errors subscribeNext:^(NSError *error) {
        DLog(@"Error: %@", error);
        NSHTTPURLResponse *response;
        if ((response = error.userInfo[@"com.alamofire.serialization.response.error.response"])) {
            // error which don't show
            if (response.statusCode == 401) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:@"Your authorization may be expired, please login again"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    @strongify(self)
                    [[DRApiClient sharedClient] logout];
                    DRLoginViewModel *viewModel = [[DRLoginViewModel alloc] initWithService:self.viewModel.services andParams:nil];
                    [self.viewModel.services presentViewModel:viewModel animated:YES completion:nil];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [DRSharedAppDelegate.navigationControllerStack.topNavigationController presentViewController:alert animated:YES completion:nil];
            }else{
                [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:1.5];
            }
        } else {
            [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:1.5];
        }
    }];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [UIDevice currentDevice].isPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark loading view

- (void)showLoadingView {
    [self hideLoadingView];
    _loadingView = [[DRLoadingView alloc] init];
    _loadingView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)hideLoadingView {
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
