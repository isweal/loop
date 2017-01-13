//
//  DRShotDetailHeaderView.h
//  loop
//
//  Created by doom on 16/9/4.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRReactiveView.h"

@interface DRShotDetailHeaderView : UIView <DRReactiveView>

@property(weak, nonatomic) IBOutlet YYAnimatedImageView *shotImageView;

@end
