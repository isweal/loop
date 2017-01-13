//
//  DRNodeRightViewController.h
//  loop
//
//  Created by doom on 16/7/8.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRViewController.h"

@interface DRNodeRightViewController : DRViewController

@property(nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);

@end
