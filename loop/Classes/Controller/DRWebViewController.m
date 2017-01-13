//
//  DRWebViewController.m
//  loop
//
//  Created by doom on 2016/11/23.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRWebViewController.h"

#import "DRWebViewModel.h"

#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface DRWebViewController () <UIWebViewDelegate>

@property(nonatomic, strong, readonly) DRWebViewModel *viewModel;

@property(nonatomic, strong) NJKWebViewProgress *progressProxy;
@property(nonatomic, strong) NJKWebViewProgressView *progressView;

@end

@implementation DRWebViewController

@dynamic viewModel;

- (void)viewDidLoad {
    self.request = self.viewModel.request;
    [super viewDidLoad];

    _progressProxy = [[NJKWebViewProgress alloc] init];
    self.delegate = _progressProxy;
    @weakify(self);
    _progressProxy.progressBlock = ^(float progress) {
        @strongify(self);
        [self.progressView setProgress:progress animated:YES];
    };

    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _progressView.progressBarView.backgroundColor = [UIColor colorWithHexString:@"0x3abd79"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
