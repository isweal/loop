//
//  DRCollectionViewController.h
//  loop
//
//  Created by doom on 16/8/12.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRViewController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface DRCollectionViewController : DRViewController<UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

// if you don't want set the delegate of  DZNEmpty, set this NO before [super viewDidLoad];
@property(nonatomic, assign) BOOL showDZNEmpty;

@end
