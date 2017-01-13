//
//  DRUserListViewController.m
//  loop
//
//  Created by doom on 2016/11/21.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRUserListViewController.h"

#import "DRUserListViewModel.h"
#import "DRUserListViewCellViewModel.h"

#import "DRUserListTableViewCell.h"

#import "DRHelper.h"

#import "DRUser.h"
#import "DRTransactionModel.h"

@interface DRUserListViewController ()

@property(nonatomic, strong, readonly) DRUserListViewModel *viewModel;

@end

@implementation DRUserListViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 56;
    regTableClass(self.tableView, [DRUserListTableViewCell class]);
}

- (void)bindViewModel {
    [super bindViewModel];

    @weakify(self)
    [[[RACObserve(self.viewModel, users)
            filter:^BOOL(NSArray *users) {
                return users.count > 0;
            }] deliverOn:[RACScheduler scheduler]]
            subscribeNext:^(NSArray *users) {
                @strongify(self)
                if (self.viewModel.dataSource == nil || self.viewModel.page == 1) {
                    self.viewModel.dataSource = [self viewModelsWithUsers:users];
                } else {
                    NSMutableArray *viewModels = [NSMutableArray array];
                    [viewModels addObjectsFromArray:self.viewModel.dataSource];
                    [viewModels addObjectsFromArray:[self viewModelsWithUsers:users]];
                    self.viewModel.dataSource = [viewModels copy];
                }
            }];
}

- (NSArray *)viewModelsWithUsers:(NSArray *)users {
    return [users.rac_sequence map:^id(id value) {
        DRUser *user;
        if ([value isKindOfClass:[DRUser class]]) {
            user = value;
        } else if ([value isKindOfClass:[DRTransactionModel class]]) {
            user = ((DRTransactionModel *) value).user;
        }
        DRUserListViewCellViewModel *viewModel = [[DRUserListViewCellViewModel alloc] initWithUser:user];
        return viewModel;
    }].array;
}

#pragma mark table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DRUserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DRUserListTableViewCell className]];
    [cell bindViewModel:self.viewModel.dataSource[indexPath.row]];
    return cell;
}

@end
