//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "DRViewController.h"

@interface SVWebViewController : DRViewController <UIWebViewDelegate>

@property(nonatomic, strong) NSURLRequest *request;
@property(nonatomic, weak) id <UIWebViewDelegate> delegate;

@property(nonatomic, strong) UIWebView *webView;

@end
