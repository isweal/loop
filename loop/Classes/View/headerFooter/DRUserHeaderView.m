//
//  DRUserHeaderView.m
//  loop
//
//  Created by doom on 2016/10/20.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRUserHeaderView.h"

#import "DRUserHeaderViewModel.h"

#import "DRApiClient.h"
#import "DSCountDownUtil.h"
#import "DRHelper.h"

#import "DRApiResponse.h"
#import "DRUser.h"

@interface DRUserHeaderView ()

@property(weak, nonatomic) IBOutlet UIImageView *backImageView;

@property(weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *locationLabel;

@property(weak, nonatomic) IBOutlet UIButton *followButton;
@property(weak, nonatomic) IBOutlet UIButton *twitterButton;
@property(weak, nonatomic) IBOutlet UIButton *siteButton;
@property(weak, nonatomic) IBOutlet UIImageView *userImageView;

@property(weak, nonatomic) IBOutlet UILabel *followerLabel;
@property(weak, nonatomic) IBOutlet UIButton *followerButton;

@property(weak, nonatomic) IBOutlet UILabel *followingLabel;
@property(weak, nonatomic) IBOutlet UIButton *followingButton;

@property(weak, nonatomic) IBOutlet UILabel *shotLabel;
@property(weak, nonatomic) IBOutlet UIButton *shotButton;

@property(weak, nonatomic) IBOutlet UILabel *likeLabel;
@property(weak, nonatomic) IBOutlet UIButton *likeButton;

@property(nonatomic, strong) DRUserHeaderViewModel *viewModel;

@end

@implementation DRUserHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    _followButton.layer.cornerRadius = _followButton.size.height / 2;
    _followButton.layer.borderWidth = 2;
    _followButton.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)bindViewModel:(DRUserHeaderViewModel *)viewModel {
    self.viewModel = viewModel;

    @weakify(self)
    [[RACObserve(self.viewModel, showShotUrl)
            takeUntil:viewModel.reuse]
            subscribeNext:^(NSString *showShotUrl) {
                @strongify(self)
                [self.backImageView setImageWithURL:[NSURL URLWithString:viewModel.showShotUrl] placeholder:nil
                                            options:YYWebImageOptionSetImageWithFadeAnimation
                                            manager:[DRHelper avatarImageManager]
                                           progress:nil transform:nil completion:nil];
            }];

    [[RACObserve(self.viewModel, contentOffsetY)
            takeUntil:viewModel.reuse]
            subscribeNext:^(id x) {
                @strongify(self)
                //TODO: ok, get the y
            }];

    _userNameLabel.text = viewModel.user.username;
    _locationLabel.text = viewModel.user.location;
    [_userImageView setImageWithURL:[NSURL URLWithString:viewModel.user.avatar_url] placeholder:nil
                            options:YYWebImageOptionSetImageWithFadeAnimation
                            manager:[DRHelper avatarImageManager] progress:nil transform:nil completion:nil];
    _followingLabel.text = viewModel.user.followings_count.stringValue;

    NSString *(^toString)(NSNumber *) = ^(NSNumber *value) {
        NSString *string = value.stringValue;
        return string;
    };

    RAC(self.followerLabel, text) = [[RACObserve(viewModel.user, followers_count) map:toString]
            takeUntil:viewModel.reuse];
    _shotLabel.text = viewModel.user.shots_count.stringValue;
    _likeLabel.text = viewModel.user.likes_count.stringValue;

    [[[RACSignal combineLatest:@[RACObserve([DRApiClient sharedClient], userAuthorized), RACObserve(viewModel, isFollow)]
                        reduce:^id(NSNumber *isAuth, NSNumber *isFollow) {
                            @strongify(self)
                            NSString *title = isAuth.boolValue ? (isFollow.boolValue ? @"Following" : @"Follow") : @"Follow it?";
                            [self.followButton setTitle:title forState:UIControlStateNormal];
                            return nil;
                        }]
            takeUntil:viewModel.reuse
    ] subscribeNext:^(id x) {

    }];

    [viewModel.checkFollowCommand.executing
            subscribeNext:^(NSNumber *executing) {
                if (executing.boolValue) {
                    @strongify(self)
                    self.followButton.enabled = NO;
                }
            }];
    [viewModel.checkFollowCommand.executionSignals.switchToLatest.deliverOnMainThread
            subscribeNext:^(DRApiResponse *apiResponse) {
                @strongify(self)
                self.viewModel.isFollow = YES;
                self.followButton.enabled = YES;
            }];
    [viewModel.checkFollowCommand.errors.deliverOnMainThread
            subscribeNext:^(NSError *error) {
                @strongify(self)
                if ([error.localizedDescription containsString:@"404"]) {
                    self.viewModel.isFollow = NO;
                    self.followButton.enabled = YES;
                } else {
                    @weakify(self)
                    [DSCountDownUtil startWithSecond:5 changing:^(NSInteger second) {
                        @strongify(self)
                        NSString *countString = [NSString stringWithFormat:@"%zd后重试", second];
                        [self.followButton setTitle:countString forState:UIControlStateNormal];
                    }                       complete:^(NSInteger second) {
                        [self.followButton setTitle:@"" forState:UIControlStateNormal];
                        [self.viewModel.checkFollowCommand execute:self.viewModel.user.userId];
                    }];
                }
            }];
    if ([DRApiClient sharedClient].isUserAuthorized) {
        [viewModel.checkFollowCommand execute:viewModel.user.userId];
    }

    [[self.followButton
            rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(id x) {
                @strongify(self)
                RACTuple *tuple = [RACTuple tupleWithObjects:@([DRApiClient sharedClient].isUserAuthorized), self.viewModel.user.userId, @(!self.viewModel.isFollow), nil];
                [self.viewModel.followCommand execute:tuple];
            }];
    [viewModel.followCommand.executionSignals.switchToLatest.deliverOnMainThread
            subscribeNext:^(id x) {
                @strongify(self)
                if ([x isKindOfClass:[DRApiResponse class]]) {
                    self.viewModel.isFollow = !self.viewModel.isFollow;
                } else if ([x isKindOfClass:[NSString class]]) { // auth 完成之后checkFollow
                    [self.viewModel.checkFollowCommand execute:self.viewModel.user.userId];
                }
            }];

    self.twitterButton.enabled = viewModel.user.links.twitter.length > 0;
    self.siteButton.enabled = viewModel.user.links.web.length > 0;

    [[self.twitterButton rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(id x) {
                @strongify(self)
                [self.viewModel.webCommand execute:self.viewModel.user.links.twitter];
            }];
    [[self.siteButton rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(id x) {
                @strongify(self)
                [self.viewModel.webCommand execute:self.viewModel.user.links.web];
            }];

    _followerButton.rac_command = viewModel.followerCommand;
    _followingButton.rac_command = viewModel.followingCommand;
    _shotButton.rac_command = viewModel.shotCommand;
    _likeButton.rac_command = viewModel.likeCommand;
}

@end
