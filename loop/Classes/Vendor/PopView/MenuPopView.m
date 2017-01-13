//
//  MenuPopView.m
//  loop
//
//  Created by doom on 16/7/7.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "MenuPopView.h"
#import "DRHelper.h"

#define kMenuPopViewFont [UIFont fontWithName:@"AvenirNext-DemiBoldItalic" size:14]

static const CGFloat kPopRowHeight = 35;
static const CGFloat kPopRowImageWidth = 40;
static const CGFloat kPopRowSpace = 80;

@interface MenuPopView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIVisualEffectView *effectView;
@property(nonatomic, strong) NSArray *titleArray;
@property(nonatomic, strong) NSArray *imageArray;

@end

@implementation MenuPopView

- (instancetype)initWithTitles:(NSArray *)titles images:(NSArray *)images {
    self = [super initWithFrame:kScreen_Bounds];
    if (self) {
        self.titleArray = titles;
        self.imageArray = images;
        self.endPoint = CGPointMake(kScreen_Width / 2, kScreen_Height / 2);
        self.startPoint = self.endPoint;
        _enableFitCellWidth = YES;
        _fillWindow = YES;
        _curIndex = 0;

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
        [self.tableView reloadData];
    }
    return self;
}

- (void)refreshSize {
    self.frame = kScreen_Bounds;
    if (_fillWindow) {
        self.effectView.frame = kScreen_Bounds;
    }

    if (_enableFitCellWidth) {
        for (NSString *title in self.titleArray) {
            NSDictionary *attribute = @{NSFontAttributeName : kMenuPopViewFont};
            CGFloat width = [title boundingRectWithSize:CGSizeMake(300, 100) options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size.width;
            self.tableView.width = MAX(width, self.tableView.size.width);
        }

        if (_imageArray.count > 0) {
            self.tableView.width += kPopRowImageWidth;
        }
        self.tableView.width += kPopRowSpace;
    } else {
        self.tableView.width = _cellWidth;
    }
    self.tableView.height = [self.titleArray count] * kPopRowHeight;

    self.tableView.center = self.startPoint;
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    [window addSubview:self];

    self.alpha = 0.f;
    self.tableView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
        self.tableView.center = self.endPoint;
    }                completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.tableView.transform = CGAffineTransformIdentity;
        }                completion:nil];
    }];
}

- (void)dismiss {
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animate {
    if (!animate) {
        [self removeFromSuperview];
        return;
    }

    [UIView animateWithDuration:0.3f animations:^{
        self.tableView.center = self.startPoint;
        self.tableView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    }                completion:^(BOOL finished) {
        [self removeFromSuperview];
        // 一定要记得还原啊,不然后面resize的时候会出问题
        self.tableView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark gesture delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"];
}


#pragma mark table view delegate

- (UITableView *)tableView {
    if (_tableView != nil) {
        return _tableView;
    }

    _tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.layer.cornerRadius = 4;
        tableView.layer.masksToBounds = YES;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.alwaysBounceVertical = NO;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.scrollEnabled = NO;
        tableView.backgroundColor = kDefaultBackGroundColor;
        regTableClass(tableView, [UITableViewCell class]);
        tableView;
    });

    [self addSubview:_tableView];

    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray ? _titleArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell className]];
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.textLabel.font = kMenuPopViewFont;
    cell.textLabel.textColor = kDefaultTextContentColor;
    if (indexPath.row == _curIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLOCK_EXEC(self.selectRowAtIndex, indexPath.row);
    _curIndex = indexPath.row;
    [self dismiss:YES];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kPopRowHeight;
}

#pragma mark effect view getter

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [self addSubview:_effectView];
        [self bringSubviewToFront:self.tableView];
    }
    return _effectView;
}


@end
