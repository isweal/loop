//
//  DRLoadingView.m
//  loop
//
//  Created by doom on 16/7/7.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRLoadingView.h"

@interface DRLoadingView ()

@property(nonatomic, copy) void (^failure)();
@property(nonatomic, strong) UILabel *whatTheLabel;

@end

@implementation DRLoadingView

+ (NSArray *)whatTheString {
    static NSArray *_whatTheString;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _whatTheString = @[@"Justice has come",
                @"For those extra long days",
                @"Long may the sun shine",
                @"I smell magic in the air",
                @"In Nordrassil's name"];
    });
    return _whatTheString;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _animatedImageView = [[YYAnimatedImageView alloc] initWithImage:[YYImage imageNamed:@"processing.gif"]];
        _animatedImageView.userInteractionEnabled = YES;
        [self addSubview:_animatedImageView];
        [_animatedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-32);
        }];
        _whatTheLabel = [UILabel new];
        _whatTheLabel.textAlignment = NSTextAlignmentCenter;
        _whatTheLabel.numberOfLines = 0;

        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            [array addObject:@(i)];
        }
        _whatTheLabel.text = [[array randomObject] boolValue] ? @"Loading" : [[DRLoadingView whatTheString] randomObject];

        _whatTheLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:12];
        [self addSubview:_whatTheLabel];
        [_whatTheLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(_animatedImageView.mas_bottom).offset(6);
            make.left.mas_equalTo(100);
        }];
    }
    return self;
}

- (void)performFailure:(void (^)(void))failure {
    _animatedImageView.image = [UIImage imageNamed:@"icon-broken"];
    _whatTheLabel.text = @"Load error, tap to retry";
    self.failure = failure;
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    [_animatedImageView startAnimating];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [_animatedImageView stopAnimating];
}

#pragma mark gesture getter

- (void)setFailure:(void (^)())failure {
    if (!_failure) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_animatedImageView addGestureRecognizer:tapGestureRecognizer];
    }
    _failure = failure;
}

- (void)tapAction {
    BLOCK_EXEC(_failure);
}

@end
