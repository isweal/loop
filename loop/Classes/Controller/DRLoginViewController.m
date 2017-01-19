//
//  DRLoginViewController.m
//  loop
//
//  Created by doom on 16/7/4.
//  Copyright © 2016年 DOOM. All rights reserved.
//


#import "DRLoginViewController.h"

#import "DRLoginViewModel.h"
#import "DRApiClient.h"

@interface DRLoginViewController ()

@property(nonatomic, strong, readonly) DRLoginViewModel *viewModel;

@end

@implementation DRLoginViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self.viewModel;

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    cancelItem.rac_command = self.viewModel.cancelCommand;
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self.viewModel.authCommand execute:self.webView] deliverOnMainThread];
}

@end
