//
//  DRNodeRightViewController.m
//  loop
//
//  Created by doom on 16/7/8.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRNodeRightViewController.h"
#import "DRShotCategory.h"
#import "DRHelper.h"

@interface DRNodeRightViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView *tableView;

@end

@implementation DRNodeRightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.backgroundColor = kDefaultBackGroundColor;
        regTableClass(tableView, [UITableViewCell class]);
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView;
    });
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DRShotCategory allCategories].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell className]];
    cell.textLabel.text = ((DRShotCategory *) [DRShotCategory allCategories][indexPath.row]).categoryName;
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBoldItalic" size:14];
    cell.textLabel.textColor = kDefaultTextContentColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLOCK_EXEC(_selectRowAtIndex, indexPath.row);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
