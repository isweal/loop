//
//  DRUserViewController.m
//  loop
//
//  Created by doom on 2016/10/20.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRUserViewController.h"

#import "DRShotCollectionViewCell.h"
#import "DRUserHeaderView.h"

#import "DRUserViewModel.h"

#import "DRShot.h"

#import "DRHelper.h"

@interface DRUserViewController () <UINavigationControllerDelegate>

@property(nonatomic, strong, readonly) DRUserViewModel *viewModel;

@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@end

@implementation DRUserViewController

@dynamic viewModel;

- (void)viewDidLoad {
    self.showDZNEmpty = NO;
    [super viewDidLoad];

    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"LogOut" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.rightBarButtonItem.rac_command = self.viewModel.logOutCommand;

    regSupplementaryNib(self.collectionView, [DRUserHeaderView class], UICollectionElementKindSectionHeader);
}

- (void)bindViewModel {
    [super bindViewModel];

    @weakify(self)
    [RACObserve(self.collectionView, contentOffset) subscribeNext:^(id x) {
        @strongify(self)
        self.viewModel.userHeaderViewModel.contentOffsetY = self.collectionView.contentOffset.y;
    }];

    [[RACObserve(self.viewModel.userHeaderViewModel, user)
            filter:^BOOL(DRUser *user) {
                return user != nil;
            }].deliverOnMainThread
            subscribeNext:^(DRUser *user) {
                @strongify(self)
                self.viewModel.title = user.name;
                self.flowLayout.headerReferenceSize = CGSizeMake(kScreen_Width, 300);
                
                [self.viewModel.showLogOutItemSignal subscribeNext:^(NSNumber *show) {
                    @strongify(self)
                    self.navigationItem.rightBarButtonItem = show.boolValue ? self.rightBarButtonItem : nil;
                }];
            }];
}

#pragma mark collection view delegate

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section == 0) {
        DRUserHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[DRUserHeaderView className] forIndexPath:indexPath];
        self.viewModel.userHeaderViewModel.reuse = headerView.rac_prepareForReuseSignal;
        [headerView bindViewModel:self.viewModel.userHeaderViewModel];
        return headerView;
    }
    return nil;
}

@end
