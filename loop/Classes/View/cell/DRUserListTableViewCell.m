//
//  DRUserListTableViewCell.m
//  loop
//
//  Created by doom on 2016/11/21.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRUserListTableViewCell.h"

#import "DRUserListViewCellViewModel.h"

#import "DRUser.h"

#import "DRHelper.h"

@interface DRUserListTableViewCell ()

@property(nonatomic, strong) DRUserListViewCellViewModel *viewModel;

@end

@implementation DRUserListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _userImageView = [UIImageView new];
        [self.contentView addSubview:_userImageView];
        [_userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_equalTo(8);
            make.width.height.mas_equalTo(40);
            make.bottom.mas_equalTo(-8);
        }];

        _userLabel = [UILabel new];
        _userLabel.font = [UIFont systemFontOfSize:kDefaultUserNameFont];
        [self.contentView addSubview:_userLabel];
        [_userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.userImageView.mas_right).offset(8);
            make.centerY.equalTo(self.userImageView);
            make.right.mas_equalTo(-8);
        }];
    }
    return self;
}

- (void)bindViewModel:(DRUserListViewCellViewModel *)viewModel {
    self.viewModel = viewModel;
    DRUser *user = self.viewModel.user;
    if (user) {
        [_userImageView setImageWithURL:[NSURL URLWithString:user.avatar_url] placeholder:nil
                                options:YYWebImageOptionSetImageWithFadeAnimation
                                manager:[DRHelper avatarImageManager]
                               progress:nil transform:nil completion:nil];
        _userLabel.text = user.name;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
