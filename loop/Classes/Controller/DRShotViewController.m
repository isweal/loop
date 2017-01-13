//
//  DRShotViewController.m
//  loop
//
//  Created by doom on 2016/11/22.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShotViewController.h"

#import "DRShotCollectionViewCell.h"

#import "DRHelper.h"

#import "DRShotViewModel.h"
#import "DRShotCollectionViewCellViewModel.h"

#import "DRShot.h"
#import "DRTransactionModel.h"

@interface DRShotViewController ()

@property(nonatomic, strong, readonly) DRShotViewModel *viewModel;

@end

@implementation DRShotViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat itemWidth;
    if (kScreen_Width > 320) {
        itemWidth = self.view.bounds.size.width / 2 - 8;
    } else {
        itemWidth = self.view.bounds.size.width - 6;
    }
    self.flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth * 3 / 4 + 30);
    self.flowLayout.sectionInset = UIEdgeInsetsMake(4, 3, 0, 3);
    regCollectionNib(self.collectionView, [DRShotCollectionViewCell class]);
}

- (void)bindViewModel {
    [super bindViewModel];

    @weakify(self)
    [[[RACObserve(self.viewModel, shots)
            filter:^BOOL(NSArray *shots) {
                return shots.count > 0;
            }] deliverOn:[RACScheduler scheduler]]
            subscribeNext:^(NSArray *shots) {
                @strongify(self)
                if (self.viewModel.dataSource == nil || self.viewModel.page == 1) {
                    self.viewModel.dataSource = [self viewModelsWithShots:shots];
                } else {
                    NSMutableArray *viewModels = [NSMutableArray array];
                    [viewModels addObjectsFromArray:self.viewModel.dataSource];
                    [viewModels addObjectsFromArray:[self viewModelsWithShots:shots]];
                    self.viewModel.dataSource = [viewModels copy];
                }
            }];
}

- (NSArray *)viewModelsWithShots:(NSArray *)shots {
    return [shots.rac_sequence map:^id(id object) {
        DRShot *shot;
        if ([object isKindOfClass:[DRShot class]]){
            shot = object;
        } else if ([object isKindOfClass:[DRTransactionModel class]]){
            shot = ((DRTransactionModel *)object).shot;
        }
        DRShotCollectionViewCellViewModel *viewModel = [[DRShotCollectionViewCellViewModel alloc] initWithShot:shot];
        return viewModel;
    }].array;
}

#pragma mark collection view delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DRShotCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DRShotCollectionViewCell className] forIndexPath:indexPath];
    [cell bindViewModel:self.viewModel.dataSource[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DRShotCollectionViewCell *cell = (DRShotCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    self.selectImage = cell.shotImageView.image;
    self.selectImageConvertFrame = [cell.shotImageView convertRect:cell.shotImageView.frame toView:self.view];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.viewModel.didSelectCommand execute:RACTuplePack(indexPath, cell.shotImageView.image)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
