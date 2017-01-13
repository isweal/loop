//
//  MenuPopView.h
//  loop
//
//  Created by doom on 16/7/7.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuPopView : UIView

- (instancetype)initWithTitles:(NSArray *)titles images:(NSArray *)images;

/**
 *  call it after init or when you set any property
 */
- (void)refreshSize;

- (void)show;

- (void)dismiss;

- (void)dismiss:(BOOL)animated;

/**
 *  default is YES, if YES, it will bring a blur effect when show
 */
@property(nonatomic, assign) BOOL fillWindow;

/**
 *  defalu is YES, if set NO, you should set cellWidth
 */
@property(nonatomic, assign) BOOL enableFitCellWidth;
@property(nonatomic, assign) CGFloat cellWidth;
@property(nonatomic, assign) CGPoint startPoint; // default is center
@property(nonatomic, assign) CGPoint endPoint; //default is center

@property(nonatomic, assign) NSInteger curIndex; // default is 0
@property(nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);

@end
