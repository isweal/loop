//
//  DRShotDetailHeaderView.m
//  loop
//
//  Created by doom on 16/9/4.
//  Copyright © 2016年 DOOM. All rights reserved.
//
// 这个页面的xib运行时会报警告，但是显示得很正常
// 我尝试着去消除这些警告，可是后来反而发现显示不正常了。。。

#import "DRShotDetailHeaderView.h"

#import "DRShotDetailHeaderViewModel.h"

#import "DRApiClient.h"
#import "DRApiResponse.h"
#import "DSCountDownUtil.h"
#import "DRHelper.h"
#import "YYPhotoGroupView.h"

#import "DRTransactionModel.h"

@interface DRShotDetailHeaderView ()

@property(weak, nonatomic) IBOutlet NSLayoutConstraint *shotImageViewHeight;
@property(weak, nonatomic) IBOutlet UIButton *likeShotButton;
@property(weak, nonatomic) IBOutlet YYLabel *contentLabel;
@property(weak, nonatomic) IBOutlet UILabel *userLabel;
@property(weak, nonatomic) IBOutlet UILabel *publishTimeLabel;
@property(weak, nonatomic) IBOutlet UIButton *userButton;

@property(weak, nonatomic) IBOutlet UILabel *viewCountsLabel;
@property(weak, nonatomic) IBOutlet UIButton *viewButton;

@property(weak, nonatomic) IBOutlet UILabel *likeCountsLabel;
@property(weak, nonatomic) IBOutlet UIButton *likesButton;

@property(weak, nonatomic) IBOutlet UILabel *bucketCountsLabel;
@property(weak, nonatomic) IBOutlet UIButton *bucketButton;

@property(weak, nonatomic) IBOutlet UILabel *commentCountsLabel;
@property(weak, nonatomic) IBOutlet UIButton *commentButton;

@property(nonatomic, strong) UITapGestureRecognizer *tapShotImageGesture;

@property(nonatomic, strong) CAShapeLayer *progressLayer;

@property(nonatomic, strong) DRShotDetailHeaderViewModel *viewModel;

@end

@implementation DRShotDetailHeaderView

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(_contentLabel.frame);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _shotImageViewHeight.constant = kScreenWidth * 3 / 4;

    CGFloat lineHeight = 4;
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.size = CGSizeMake(_shotImageView.width, lineHeight);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, _progressLayer.height / 2)];
    [path addLineToPoint:CGPointMake(_shotImageView.width, _progressLayer.height / 2)];
    _progressLayer.lineWidth = lineHeight;
    _progressLayer.path = path.CGPath;
    _progressLayer.strokeColor = [UIColor colorWithRed:0.000 green:0.640 blue:1.000 alpha:0.720].CGColor;
    _progressLayer.lineCap = kCALineCapButt;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    [_shotImageView.layer addSublayer:_progressLayer];

    _tapShotImageGesture = [[UITapGestureRecognizer alloc] init];
    [_shotImageView addGestureRecognizer:_tapShotImageGesture];

    @weakify(self)
    _contentLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        @strongify(self)
        YYTextHighlight *highlight = [text attribute:YYTextHighlightAttributeName atIndex:range.location];
        DRHtmlMediaItem *htmlMediaItem = highlight.userInfo[kDRHtmlMediaItemName];
        [self.viewModel.didClickUrlCommand execute:htmlMediaItem];
    };
}

- (void)bindViewModel:(DRShotDetailHeaderViewModel *)viewModel {
    self.viewModel = viewModel;

    @weakify(self)
    [[[RACObserve(self.viewModel, shot.images.show)
            filter:^BOOL(NSString *show) {
                return show.length > 0;
            }] map:^id(NSString *show) {
        return [NSURL URLWithString:show];
    }] subscribeNext:^(NSURL *showUrl) {
        @strongify(self)
        [self.shotImageView setImageWithURL:showUrl placeholder:viewModel.shotImage
                                    options:YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                       if (expectedSize > 0 && receivedSize > 0) {
                                           @strongify(self)
                                           CGFloat progress = (CGFloat) receivedSize / expectedSize;
                                           progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
                                           if (self.progressLayer.hidden) self.progressLayer.hidden = NO;
                                           self.progressLayer.strokeEnd = progress;
                                       }
                                   } transform:nil
                                 completion:^(UIImage *_Nullable image, NSURL *_Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError *_Nullable error) {
                                     if (stage == YYWebImageStageFinished) {
                                         @strongify(self)
                                         self.progressLayer.hidden = YES;
                                     }
                                 }];
    }];

    [[self.tapShotImageGesture rac_gestureSignal]
            subscribeNext:^(id x) {
                @strongify(self)
                NSMutableArray *items = [NSMutableArray array];
                YYPhotoGroupItem *item = [YYPhotoGroupItem new];
                item.thumbView = self.shotImageView;
                item.largeImageURL = [NSURL URLWithString:self.viewModel.shot.images.show];
                [items addObject:item];

                YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
                [v presentFromImageView:self.shotImageView
                            toContainer:DRSharedAppDelegate.navigationControllerStack.topNavigationController.view
                               animated:YES completion:nil];
            }];

    [RACObserve(self.viewModel, shotDescription) subscribeNext:^(NSAttributedString *shotDescription) {
        @strongify(self)
        self.contentLabel.attributedText = shotDescription;
    }];

    RAC(self.userLabel, text) = RACObserve(self.viewModel, shot.user.name);
    RAC(self.publishTimeLabel, text) = RACObserve(self.viewModel, shot.createdTime);
    RAC(self.viewCountsLabel, text) = RACObserve(self.viewModel, shot.views_count.stringValue);
    RAC(self.bucketCountsLabel, text) = RACObserve(self.viewModel, shot.buckets_count.stringValue);

    [[[RACObserve(self.viewModel, shot.user.avatar_url)
            filter:^BOOL(NSString *avatar) {
                return avatar.length > 0;
            }] map:^id(NSString *avatar) {
        return [NSURL URLWithString:avatar];
    }] subscribeNext:^(NSURL *avatarUrl) {
        @strongify(self)
        [self.userButton setImageWithURL:avatarUrl forState:UIControlStateNormal
                             placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation
                                 manager:[DRHelper avatarImageManager]
                                progress:nil transform:nil completion:nil];
    }];


    NSString *(^toString)(NSNumber *) = ^(NSNumber *value) {
        NSString *string = value.stringValue;
        return string;
    };

    RAC(self.likeCountsLabel, text) = [RACObserve(viewModel, shot.likes_count) map:toString];
    RAC(self.commentCountsLabel, text) = [RACObserve(viewModel, shot.comments_count) map:toString];

    [[[RACSignal combineLatest:@[RACObserve([DRApiClient sharedClient], userAuthorized), RACObserve(viewModel, isLike)] reduce:^id(NSNumber *isAuth, NSNumber *isLike) {
        @strongify(self)
        NSString *title = isAuth.boolValue ? (isLike.boolValue ? @"i like it" : @"like it?") : @"like it?";
        UIImage *image = [UIImage imageNamed:isAuth.boolValue ? (isLike.boolValue ? @"icon_tick_16" : @"icon_fork_16") : @"icon_fork_16"];
        UIColor *color = [UIColor colorWithHexString:isLike.boolValue ? @"ec4989" : @"9a9a9a"];
        [self.likeShotButton setTitle:title forState:UIControlStateNormal];
        [self.likeShotButton setImage:image forState:UIControlStateNormal];
        self.likeShotButton.backgroundColor = color;
        return nil;
    }] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {

    }];

    // checkLikeCommand
    [viewModel.checkLikeCommand.executing
            subscribeNext:^(NSNumber *executing) {
                if (executing.boolValue) {
                    @strongify(self)
                    self.likeShotButton.enabled = NO;
                }
            }];
    [viewModel.checkLikeCommand.executionSignals.switchToLatest.deliverOnMainThread
            subscribeNext:^(DRApiResponse *apiResponse) {
                @strongify(self)
                DRTransactionModel *model = apiResponse.object;
                self.viewModel.isLike = model.created_at.length > 0;
                self.likeShotButton.enabled = YES;
            }];
    [viewModel.checkLikeCommand.errors.deliverOnMainThread
            subscribeNext:^(NSError *error) {
                @strongify(self)
                // 不想去获取statusCode了
                // ((NSHTTPURLResponse *)response).statusCode
                if ([error.localizedDescription containsString:@"404"]) {
                    self.viewModel.isLike = NO;
                    self.likeShotButton.enabled = YES;
                } else {
                    @weakify(self)
                    [DSCountDownUtil startWithSecond:5 changing:^(NSInteger second) {
                        @strongify(self)
                        NSString *countString = [NSString stringWithFormat:@"%zd后重试", second];
                        [self.likeShotButton setTitle:countString forState:UIControlStateNormal];
                    }                       complete:^(NSInteger second) {
                        [self.likeShotButton setTitle:@"" forState:UIControlStateNormal];
                        [self.viewModel.checkLikeCommand execute:self.viewModel.shot.shotId];
                    }];
                }
            }];

    if ([DRApiClient sharedClient].isUserAuthorized) {
        [viewModel.checkLikeCommand execute:viewModel.shot.shotId];
    }

    [[self.likeShotButton
            rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(id x) {
                @strongify(self)
                RACTuple *tuple = [RACTuple tupleWithObjects:@([DRApiClient sharedClient].isUserAuthorized), self.viewModel.shot.shotId, @(!self.viewModel.isLike), nil];
                [self.viewModel.likeShotCommand execute:tuple];
            }];
    [viewModel.likeShotCommand.executionSignals.switchToLatest.deliverOnMainThread
            subscribeNext:^(id x) {
                @strongify(self)
                if ([x isKindOfClass:[DRApiResponse class]]) {
                    self.viewModel.isLike = !self.viewModel.isLike;
                } else if ([x isKindOfClass:[NSString class]]) { // auth 完成之后checkLike
                    [self.viewModel.checkLikeCommand execute:self.viewModel.shot.shotId];
                }
            }];

    [[self.userButton
            rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(id x) {
                @strongify(self)
                [self.viewModel.userCommand execute:self.viewModel.shot.user];
            }];
    [[self.likesButton
            rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(id x) {
                @strongify(self)
                [self.viewModel.likesCommand execute:self.viewModel.shot.user.userId];
            }];
    [[self.bucketButton
            rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(id x) {
                @strongify(self)
                [self.viewModel.bucketCommand execute:self.viewModel.shot.user.userId];
            }];
    [[self.commentButton
            rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(id x) {
                @strongify(self)
                [self.viewModel.commentCommand execute:self.viewModel.shot.user.userId];
            }];
}

@end
