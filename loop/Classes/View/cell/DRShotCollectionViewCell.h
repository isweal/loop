//
//  DRShotCollectionViewCell.h
//  loop
//
//  Created by doom on 16/7/4.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRReactiveView.h"

@class DRShotCollectionViewCellViewModel;

@interface DRShotCollectionViewCell : UICollectionViewCell<DRReactiveView>

@property(weak, nonatomic) IBOutlet UIImageView *shotImageView;
@property(weak, nonatomic) IBOutlet UIImageView *userImageView;
@property(weak, nonatomic) IBOutlet UILabel *viewsCount;
@property(weak, nonatomic) IBOutlet UILabel *commentsCount;
@property(weak, nonatomic) IBOutlet UILabel *likesCount;

@end
