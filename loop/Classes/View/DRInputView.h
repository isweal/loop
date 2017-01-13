//
//  DRInputView.h
//  loop
//
//  Created by doom on 2017/1/6.
//  Copyright © 2017年 DOOM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DRInputViewType) {
    DRInputViewTypeShotComment = 0,
};

@protocol DRInputViewDelegate;

@interface DRInputView : UIView

@property(nonatomic, strong) UITextView *inputTextView;
@property(nonatomic, copy) NSString *placeHolder;
@property(nonatomic, assign) BOOL isAlwaysShow;
@property(nonatomic, assign, readonly) DRInputViewType inputViewType;

@property(nonatomic, weak) id <DRInputViewDelegate> delegate;

+ (instancetype)inputViewWithType:(DRInputViewType)inputViewType;

+ (instancetype)inputViewWithType:(DRInputViewType)inputViewType placeHolder:(NSString *)placeHolder;

- (BOOL)isAndResignFirstResponder;

- (void)show;

- (void)dismiss;

@end

@protocol DRInputViewDelegate <NSObject>
@optional
- (void)inputView:(DRInputView *)inputView sendText:(NSString *)text;

@end