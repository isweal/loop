//
//  DRReactiveView.h
//  loop
//
//  Created by doom on 16/9/4.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DRReactiveView <NSObject>

- (void)bindViewModel:(id)viewModel;

@end
