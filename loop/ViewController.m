//
//  ViewController.m
//  loop
//
//  Created by doom on 16/6/24.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "ViewController.h"
#import "DRLoginViewController.h"
#import "DRApiClient.h"

@interface ViewController ()

@property(nonatomic, strong) YYAnimatedImageView *webImageView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webImageView = [YYAnimatedImageView new];
    _webImageView.clipsToBounds = YES;
    _webImageView.contentMode = UIViewContentModeScaleAspectFill;
    _webImageView.backgroundColor = [UIColor lightGrayColor];
    _webImageView.frame = CGRectMake(8, 200, 200, 200*3/4);
    [self.view addSubview:_webImageView];
    
    CGFloat lineHeight = 4;
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.size = CGSizeMake(_webImageView.width, lineHeight);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, _progressLayer.height / 2)];
    [path addLineToPoint:CGPointMake(_webImageView.width, _progressLayer.height / 2)];
    _progressLayer.lineWidth = lineHeight;
    _progressLayer.path = path.CGPath;
    _progressLayer.strokeColor = [UIColor colorWithRed:0.000 green:0.640 blue:1.000 alpha:0.720].CGColor;
    _progressLayer.lineCap = kCALineCapButt;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    [_webImageView.layer addSublayer:_progressLayer];
    
    __weak typeof(self) _self = self;
    [_webImageView setImageWithURL:[NSURL URLWithString:@"https://d13yacurqjgara.cloudfront.net/users/566817/screenshots/2815864/lagifathon03_dribbble.gif"]
                       placeholder:nil
                           options:YYWebImageOptionProgressiveBlur | YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation
                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                              if (expectedSize > 0 && receivedSize > 0) {
                                  CGFloat progress = (CGFloat)receivedSize / expectedSize;
                                  progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
                                  if (_self.progressLayer.hidden) _self.progressLayer.hidden = NO;
                                  _self.progressLayer.strokeEnd = progress;
                              }
                          } transform:nil
                        completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                            if (stage == YYWebImageStageFinished) {
                                _self.progressLayer.hidden = YES;
                            }
                        }];
    
    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"1",@"2"]];
    NSLog(@"%@",tuple[0]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
