//
//  DRShotDetailCommentTableViewCell.h
//  loop
//
//  Created by doom on 16/8/23.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRReactiveView.h"

@interface DRShotDetailCommentTableViewCell : UITableViewCell<DRReactiveView>

@property(nonatomic, strong) UIImageView *userImageView;
@property(nonatomic, strong) UILabel *userLabel;
@property(nonatomic, strong) UILabel *publishTimeLabel;
@property(nonatomic, strong) YYLabel *contentLabel;

@end
