//
//  DRInputView.m
//  loop
//
//  Created by doom on 2017/1/6.
//  Copyright © 2017年 DOOM. All rights reserved.
//

static const CGFloat kDRInputView_Height = 50;
static const CGFloat kDRInputView_PaddingHeight = 7;
static const CGFloat kDRInputView_PaddingLeft = 15;
static const CGFloat kDRInputView_ToolBottomWidth = 35;

#import "DRInputView.h"

#import "UITextView+Placeholder.h"
#import "UIView+Common.h"

@interface DRInputView () {
    // 协议缓存
    struct {
        unsigned int didSendText    :1;
    } _delegateFlags;
}

@property(nonatomic, strong) UIScrollView *contentView;
@property(nonatomic, strong) UIButton *sendButton;

@property(nonatomic, assign) DRInputViewType inputViewType;

@property(nonatomic, assign) CGFloat viewHeightOld;

@end

@implementation DRInputView

+ (instancetype)inputViewWithType:(DRInputViewType)inputViewType {
    return [DRInputView inputViewWithType:inputViewType placeHolder:@""];
}

+ (instancetype)inputViewWithType:(DRInputViewType)inputViewType placeHolder:(NSString *)placeHolder {
    DRInputView *inputView = [[DRInputView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kDRInputView_Height)];
    inputView.inputViewType = inputViewType;
    [inputView customUIWithType:inputViewType];
    inputView.inputTextView.placeholder = placeHolder;
    return inputView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.viewHeightOld = self.height;
        self.backgroundColor = UIColorHex(f8f8f8);
        [self addLineUp:YES andDown:NO];
        _isAlwaysShow = YES;
    }
    return self;
}

#pragma mark interface

- (void)customUIWithType:(DRInputViewType)inputViewType {
    NSInteger toolBtnNum = 1;
    CGFloat contentViewHeight = kDRInputView_Height - 2 * kDRInputView_PaddingHeight;

    if (!_contentView) {
        _contentView = ({
            UIScrollView *scrollView = [[UIScrollView alloc] init];
            scrollView.backgroundColor = [UIColor whiteColor];
            scrollView.layer.borderWidth = 0.5;
            scrollView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            scrollView.layer.cornerRadius = contentViewHeight / 2;
            scrollView.layer.masksToBounds = YES;
            scrollView.alwaysBounceVertical = YES;
            scrollView;
        });;

        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat left = kDRInputView_PaddingLeft;
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(kDRInputView_PaddingHeight, left, kDRInputView_PaddingHeight, kDRInputView_PaddingLeft + toolBtnNum * kDRInputView_ToolBottomWidth));
        }];
    }

    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - kDRInputView_PaddingLeft - toolBtnNum * kDRInputView_ToolBottomWidth - kDRInputView_PaddingLeft, contentViewHeight)];
        _inputTextView.font = [UIFont systemFontOfSize:16];
        _inputTextView.scrollsToTop = NO;

        //输入框缩进
        UIEdgeInsets insets = _inputTextView.textContainerInset;
        insets.left += 8.0;
        insets.right += 8.0;
        _inputTextView.textContainerInset = insets;

        [_contentView addSubview:_inputTextView];
    }

    if (!_sendButton) {
        _sendButton = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kDRInputView_PaddingLeft / 2 - toolBtnNum * kDRInputView_ToolBottomWidth, (kDRInputView_Height - kDRInputView_ToolBottomWidth) / 2, kDRInputView_ToolBottomWidth, kDRInputView_ToolBottomWidth)];
            [button setImage:[UIImage imageNamed:@"icon-send"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(sendTextStr) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        [self addSubview:_sendButton];
    }

    if (_inputTextView) {
        @weakify(self)
        [[RACObserve(self.inputTextView, contentSize) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSValue *contentSize) {
            @strongify(self)
            [self updateContentView];
        }];
    }
}

- (void)updateContentView {
    CGSize textSize = _inputTextView.contentSize;
    if (ABS(_inputTextView.height - textSize.height) > 0.5) {
        [_inputTextView setHeight:textSize.height];
    }
    CGSize contentSize = CGSizeMake(textSize.width, textSize.height);
    CGFloat selfHeight = MAX(kDRInputView_Height, contentSize.height + 2 * kDRInputView_PaddingHeight);

    CGFloat maxSelfHeight;
    if (kDevice_Is_iPhone5) {
        maxSelfHeight = 230;
    } else if (kDevice_Is_iPhone6) {
        maxSelfHeight = 290;
    } else if (kDevice_Is_iPhone6Plus) {
        maxSelfHeight = kScreen_Height / 2;
    } else {
        maxSelfHeight = 140;
    }

    selfHeight = MIN(maxSelfHeight, selfHeight);
    CGFloat diffHeight = selfHeight - _viewHeightOld;
    if (ABS(diffHeight) > 0.5) {
        CGRect selfFrame = self.frame;
        selfFrame.size.height += diffHeight;
        selfFrame.origin.y -= diffHeight;
        [self setFrame:selfFrame];
        self.viewHeightOld = selfHeight;
    }
    [self.contentView setContentSize:contentSize];

    CGFloat bottomY = textSize.height;
    CGFloat offsetY = MAX(0, bottomY - (CGRectGetHeight(self.frame) - 2 * kDRInputView_PaddingHeight));
    [self.contentView setContentOffset:CGPointMake(0, offsetY) animated:YES];
}

#pragma mark tool method

- (void)show {
    if (self.superview == kKeyWindow) return;
    self.top = kScreen_Height;
    [kKeyWindow addSubview:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    if (_isAlwaysShow || !self.isFirstResponder) {
        [UIView animateWithDuration:0.25 animations:^{
            self.top = kScreen_Height - self.height;
        }];
    }
}

- (void)dismiss {
    if (self.superview == nil) return;
    [self isAndResignFirstResponder];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom
                     animations:^{
                         self.top = kScreen_Height;
                     } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isAndResignFirstResponder {
    if ([_inputTextView isFirstResponder]) {
        [_inputTextView resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

- (void)sendTextStr {
    [self isAndResignFirstResponder];
    if ([_inputTextView.text stringByTrim].length > 0) {
        if (_delegateFlags.didSendText) {
            [_delegate inputView:self sendText:_inputTextView.text];
        }
    }
}

#pragma mark - KeyBoard Notification Handlers

- (void)keyboardChange:(NSNotification *)aNotification {
    if ([aNotification name] == UIKeyboardDidChangeFrameNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    if ([self.inputTextView isFirstResponder]) {
        NSDictionary *userInfo = [aNotification userInfo];
        CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardY = keyboardEndFrame.origin.y;

        CGFloat selfOriginY = keyboardY == kScreen_Height ? self.isAlwaysShow ? kScreen_Height - CGRectGetHeight(self.frame) : kScreen_Height : keyboardY - CGRectGetHeight(self.frame);
        if (selfOriginY == self.frame.origin.y) {
            return;
        }

        @weakify(self)
        void (^endFrameBlock)() = ^() {
            @strongify(self)
            self.top = selfOriginY;
        };
        if ([aNotification name] == UIKeyboardWillChangeFrameNotification) {
            NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
            [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
                endFrameBlock();
            }                completion:nil];
        } else {
            endFrameBlock();
        }
    }
}

#pragma mark setter

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    if (_inputTextView && ![_inputTextView.placeholder isEqualToString:placeHolder]) {
        _inputTextView.placeholder = placeHolder;
    }
}

- (void)setDelegate:(id <DRInputViewDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.didSendText = [_delegate respondsToSelector:@selector(inputView:sendText:)];
}

@end
