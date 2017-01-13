//
//  DRTableViewController.m
//  loop
//
//  Created by doom on 16/7/5.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRTableViewController.h"
#import "DRTableViewModel.h"

#import "ODRefreshControl.h"
#import "YYFPSLabel.h"
#import "DRLoadingView.h"

@interface DRTableViewController ()

@property(nonatomic, strong) YYFPSLabel *fpsLabel;

@property(nonatomic, strong, readonly) DRTableViewModel *viewModel;
@property(nonatomic, strong) ODRefreshControl *refreshControl;

@end

@implementation DRTableViewController

@dynamic viewModel;

- (instancetype)initWithViewModel:(DRViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.showDZNEmpty = YES;
        if (viewModel.shouldRequestRemoteDataOnViewDidLoad) {
            @weakify(self)
            [[self rac_signalForSelector:@selector(viewDidLoad)]
                    subscribeNext:^(id x) {
                        @strongify(self)
                        [self.viewModel.requestRemoteDataCommand execute:@1];
                    }];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel.firstIn = YES;
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.backgroundColor = kDefaultBackGroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        if (self.showDZNEmpty) {
            tableView.emptyDataSetDelegate = self;
            tableView.emptyDataSetSource = self;
        }
        tableView.tableFooterView = [UIView new];
        tableView;
    });
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    @weakify(self)
    [self.viewModel.requestRemoteDataCommand.executing.deliverOnMainThread subscribeNext:^(NSNumber *executing) {
        @strongify(self)

        if (self.viewModel.firstIn && executing.boolValue) {
            [self showLoadingView];

        }
    }];

    [self.viewModel.requestRemoteDataCommand.executionSignals.switchToLatest.deliverOnMainThread subscribeNext:^(id x) {
        @strongify(self)
        if (self.viewModel.firstIn) {
            [self hideLoadingView];
            self.viewModel.firstIn = NO;
        }
    }];

    [self.viewModel.requestRemoteDataCommand.errors subscribeNext:^(id x) {
        @strongify(self)
        if (self.viewModel.firstIn && self.loadingView) {
            [self.loadingView performFailure:^{
                @strongify(self)
                [self.viewModel.requestRemoteDataCommand execute:@1];
            }];
        }
    }];

    if (self.viewModel.shouldPullToRefresh) {
        self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [[self.refreshControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
            @strongify(self)
            [[[self.viewModel.requestRemoteDataCommand execute:@1] deliverOnMainThread]
                    subscribeNext:^(id x) {
                        @strongify(self)
                        self.viewModel.page = 1;
                    } error:^(NSError *error) {
                @strongify(self)
                [self.refreshControl endRefreshing];
            }           completed:^{
                @strongify(self)
                [self.refreshControl endRefreshing];
            }];
        }];
    }

#ifdef DEBUG
    self.fpsLabel = [[YYFPSLabel alloc] init];
    [self.view addSubview:self.fpsLabel];
    [self.fpsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottom.mas_equalTo(-12);
    }];
    self.fpsLabel.alpha = 0;
#endif
}

- (void)bindViewModel {
    [super bindViewModel];
    @weakify(self)
    [[[RACObserve(self.viewModel, dataSource)
            distinctUntilChanged]
            deliverOnMainThread]
            subscribeNext:^(id x) {
                @strongify(self)
                [self.tableView reloadData];
            }];
}

#pragma mark tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.shouldInfiniteScrolling) {
        if (indexPath.row != 0 && indexPath.row == [self.viewModel.dataSource count] - 1) {
            [self.viewModel.requestRemoteDataCommand execute:@(self.viewModel.page + 1)];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewModel.didSelectCommand execute:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *topNavigationController = DRSharedAppDelegate.navigationControllerStack.topNavigationController;
    DRViewController *topViewController = (DRViewController *) topNavigationController.topViewController;
    topViewController.snapShot = [topNavigationController.view snapshotViewAfterScreenUpdates:NO];

    return YES;
}

#pragma mark scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.fpsLabel.alpha = 1;
                         }
                         completion:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.fpsLabel.alpha != 0) {
        [UIView animateWithDuration:1 delay:2
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.fpsLabel.alpha = 0;
                         }
                         completion:NULL];
    }
}

#pragma mark DZEmpty dataSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc] initWithString:@"No Data"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.viewModel.dataSource == nil;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -(self.tableView.contentInset.top - self.tableView.contentInset.bottom) / 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
