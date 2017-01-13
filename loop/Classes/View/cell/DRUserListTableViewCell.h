//
//  DRUserListTableViewCell.h
//  loop
//
//  Created by doom on 2016/11/21.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRReactiveView.h"

@interface DRUserListTableViewCell : UITableViewCell <DRReactiveView>

@property(nonatomic, strong) UIImageView *userImageView;
@property(nonatomic, strong) UILabel *userLabel;

@end
