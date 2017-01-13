//
//  DRShotCollectionViewCell.m
//  loop
//
//  Created by doom on 16/7/4.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShotCollectionViewCell.h"

#import "DRShotCollectionViewCellViewModel.h"

#import "DRHelper.h"

#import "DRShot.h"

@interface DRShotCollectionViewCell ()

@property(nonatomic, strong) DRShotCollectionViewCellViewModel *viewModel;
@property(weak, nonatomic) IBOutlet UIImageView *gifSymBol;

@end

@implementation DRShotCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)bindViewModel:(DRShotCollectionViewCellViewModel *)viewModel {
    self.viewModel = viewModel;
    DRShot *shot = self.viewModel.shot;
    if(shot){
        _gifSymBol.hidden = ![[shot.images.show pathExtension] isEqualToString:@"gif"];
        [_shotImageView setImageWithURL:[NSURL URLWithString:shot.images.normal] placeholder:nil
                                options:YYWebImageOptionSetImageWithFadeAnimation
                                manager:[DRHelper avatarImageManager] progress:nil transform:nil completion:nil];
        [_userImageView setImageWithURL:[NSURL URLWithString:shot.user.avatar_url] placeholder:nil
                                options:YYWebImageOptionSetImageWithFadeAnimation
                                manager:[DRHelper avatarImageManager] progress:nil transform:nil completion:nil];
        _likesCount.text = shot.likes_count.stringValue;
        _commentsCount.text = shot.comments_count.stringValue;
        _viewsCount.text = shot.views_count.stringValue;
    }
}


@end
