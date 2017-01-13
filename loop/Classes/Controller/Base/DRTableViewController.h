//
//  DRTableViewController.h
//  loop
//
//  Created by doom on 16/7/5.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRViewController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface DRTableViewController : DRViewController <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property(nonatomic, strong) UITableView *tableView;

// if you don't want set the delegate of  DZNEmpty, set this NO before [super viewDidLoad];
@property(nonatomic, assign) BOOL showDZNEmpty;

@end
