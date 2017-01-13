//
//  DRCollectionViewController.m
//  loop
//
//  Created by doom on 16/8/12.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRCollectionViewController.h"
#import "DRCollectionViewModel.h"

#import "ODRefreshControl.h"
#import "YYFPSLabel.h"
#import "DRLoadingView.h"

@interface DRCollectionViewController ()

@property(nonatomic, strong) YYFPSLabel *fpsLabel;

@property(nonatomic, strong, readonly) DRCollectionViewModel *viewModel;
@property(nonatomic, strong) ODRefreshControl *refreshControl;

@end

@implementation DRCollectionViewController

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
    self.collectionView = ({
        _flowLayout = [UICollectionViewFlowLayout new];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
        collectionView.backgroundColor = kDefaultBackGroundColor;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        if (self.showDZNEmpty) {
            collectionView.emptyDataSetDelegate = self;
            collectionView.emptyDataSetSource = self;
        }
        collectionView.alwaysBounceVertical = YES;
        collectionView;
    });
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
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
                [self.viewModel.requestRemoteDataCommand execute:@1];
            }];
        }
    }];

    if (self.viewModel.shouldPullToRefresh) {
        self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.collectionView];
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
                [self.collectionView reloadData];
            }];
}

#pragma mark collectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.shouldInfiniteScrolling) {
        if (indexPath.row != 0 && indexPath.row == [self.viewModel.dataSource count] - 1) {
            [self.viewModel.requestRemoteDataCommand execute:@(self.viewModel.page + 1)];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.viewModel.didSelectCommand execute:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
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
    return -(self.collectionView.contentInset.top - self.collectionView.contentInset.bottom) / 2;
}

@end
