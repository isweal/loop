//
//  SVModalWebViewController.h
//
//  Created by Oliver Letterer on 13.08.11.
//  Copyright 2011 Home. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import <UIKit/UIKit.h>

@interface SVModalWebViewController : UINavigationController

- (instancetype)initWithURLRequest:(NSURLRequest *)request;

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) UIColor *barsTintColor;
@property (nonatomic, weak) id<UIWebViewDelegate> webViewDelegate;

@end
