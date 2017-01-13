//
//  DRShotDetailCommentTableViewCell.m
//  loop
//
//  Created by doom on 16/8/23.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShotDetailCommentTableViewCell.h"
#import "DRShotDetailCommentViewCellViewModel.h"
#import "DRComment.h"
#import "DRHelper.h"

@interface DRShotDetailCommentTableViewCell ()

@property(nonatomic, strong) DRShotDetailCommentViewCellViewModel *viewModel;

@end

@implementation DRShotDetailCommentTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _userImageView = [UIImageView new];
        [self.contentView addSubview:_userImageView];
        [_userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(8);
            make.left.mas_equalTo(8);
            make.width.height.mas_equalTo(40);
        }];

        _userLabel = [UILabel new];
        _userLabel.font = [UIFont systemFontOfSize:kDefaultUserNameFont];
        [self.contentView addSubview:_userLabel];
        _publishTimeLabel = [UILabel new];
        _publishTimeLabel.font = [UIFont systemFontOfSize:kDefaultContentFont];
        [self.contentView addSubview:_publishTimeLabel];

        [_publishTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-8);
            make.top.equalTo(self.userImageView.mas_top);
        }];
        [_userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userImageView.mas_top);
            make.left.equalTo(self.userImageView.mas_right).offset(8);
            make.right.greaterThanOrEqualTo(self.publishTimeLabel.mas_left).offset(-8);
        }];

        _contentLabel = [[YYLabel alloc] init];
        _contentLabel.preferredMaxLayoutWidth = kScreenWidth - 40 - 8 * 3;
        _contentLabel.numberOfLines = 0;
        [self.contentView addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.userImageView.mas_right).offset(8);
            make.top.equalTo(self.userLabel.mas_bottom).offset(8);
            make.right.mas_equalTo(-8);
            make.bottom.mas_equalTo(-8);
        }];

        @weakify(self)
        _contentLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            @strongify(self)
            YYTextHighlight *highlight = [text attribute:YYTextHighlightAttributeName atIndex:range.location];
            DRHtmlMediaItem *htmlMediaItem = highlight.userInfo[kDRHtmlMediaItemName];
            [self.viewModel.didClickUrlCommand execute:htmlMediaItem];
        };
    }
    return self;
}

- (void)bindViewModel:(DRShotDetailCommentViewCellViewModel *)viewModel {
    self.viewModel = viewModel;
    DRComment *comment = self.viewModel.comment;
    if (comment) {
        [_userImageView setImageWithURL:[NSURL URLWithString:comment.user.avatar_url] placeholder:nil
                                options:YYWebImageOptionSetImageWithFadeAnimation
                                manager:[DRHelper avatarImageManager]
                               progress:nil transform:nil completion:nil];
        _userLabel.text = comment.user.name;
        _publishTimeLabel.text = comment.createdTime;
        _contentLabel.attributedText = viewModel.content;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
