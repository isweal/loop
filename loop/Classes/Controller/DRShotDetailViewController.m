//
//  DRShotDetailViewController.m
//  loop
//
//  Created by doom on 16/7/8.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShotDetailViewController.h"

#import "DRShotDetailHeaderView.h"
#import "DRShotDetailCommentTableViewCell.h"
#import "DRInputView.h"

#import "DRHelper.h"
#import "DRApiClient.h"

#import "DRShotDetailViewModel.h"
#import "DRShotDetailHeaderViewModel.h"
#import "DRShotDetailCommentViewCellViewModel.h"

#import "DRComment.h"

@interface DRShotDetailViewController () <DRInputViewDelegate>

@property(nonatomic, strong, readonly) DRShotDetailViewModel *viewModel;

@property(nonatomic, strong) DRShotDetailHeaderView *shotDetailHeaderView;
@property(nonatomic, strong) DRInputView *inputView;

@end

@implementation DRShotDetailViewController

@dynamic viewModel;


- (void)viewDidLoad {
    self.showDZNEmpty = NO;
    [super viewDidLoad];
    regTableClass(self.tableView, [DRShotDetailCommentTableViewCell class]);
    self.tableView.estimatedRowHeight = 50;
    self.shotDetailHeaderView = [[NSBundle mainBundle] loadNibNamed:@"DRShotDetailHeaderView" owner:nil options:nil].firstObject;
    self.shotDetailHeaderView.shotImageView.hidden = YES;
    [self.shotDetailHeaderView bindViewModel:self.viewModel.shotDetailHeaderViewModel];

    //TODO: Only Player and above can upload comment and shot
    DRUser *user = [DRRouter sharedInstance].currentUser;
    if(user.can_upload_shot){
        _inputView = [DRInputView inputViewWithType:DRInputViewTypeShotComment placeHolder:@"Add a comment."];
        _inputView.delegate = self;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, _inputView.height, 0.0);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.shotDetailHeaderView.shotImageView.hidden = NO;
    if (_inputView) {
        [_inputView show];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_inputView) {
        [_inputView dismiss];
    }
    // pop
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([viewControllers indexOfObject:self] == NSNotFound) {
        self.selectImageConvertFrame = [self.shotDetailHeaderView convertRect:self.shotDetailHeaderView.shotImageView.frame toView:self.view];
        self.shotDetailHeaderView.shotImageView.hidden = YES;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.shotDetailHeaderView setNeedsLayout];
    [self.shotDetailHeaderView layoutIfNeeded];
    CGFloat height = [self.shotDetailHeaderView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    self.shotDetailHeaderView.height = height;
    self.tableView.tableHeaderView = self.shotDetailHeaderView;
}

- (void)bindViewModel {
    [super bindViewModel];

    @weakify(self)
    [[RACObserve(self.viewModel.shotDetailHeaderViewModel, shot) filter:^BOOL(DRShot *shot) {
        return shot != nil;
    }].deliverOnMainThread
            subscribeNext:^(DRShot *shot) {
                @strongify(self)
                self.viewModel.title = shot.title;
            }];

    [[[RACObserve(self.viewModel, comments)
            filter:^BOOL(NSArray *comments) {
                return comments.count > 0;
            }] deliverOn:[RACScheduler scheduler]]
            subscribeNext:^(NSArray *comments) {
                @strongify(self)
                if (self.viewModel.dataSource == nil || self.viewModel.page == 1) {
                    self.viewModel.dataSource = [self viewModelsWithComments:comments];
                } else {
                    NSMutableArray *viewModels = [NSMutableArray array];
                    [viewModels addObjectsFromArray:self.viewModel.dataSource];
                    [viewModels addObjectsFromArray:[self viewModelsWithComments:comments]];
                    self.viewModel.dataSource = [viewModels copy];
                }
            }];
}

- (NSArray *)viewModelsWithComments:(NSArray *)comments {
    return [comments.rac_sequence map:^id(DRComment *comment) {
        DRShotDetailCommentViewCellViewModel *viewModel = [[DRShotDetailCommentViewCellViewModel alloc] initWithComment:comment];
        viewModel.didClickUrlCommand = self.viewModel.didClickUrlCommand;
        return viewModel;
    }].array;
}

#pragma mark inputView delegate

- (void)inputView:(DRInputView *)inputView sendText:(NSString *)text {
    @weakify(self)
    [self.viewModel.uploadCommentCommand execute:RACTuplePack(self.viewModel.shot.shotId, text)];
    [self.viewModel.uploadCommentCommand.executionSignals.switchToLatest.deliverOnMainThread subscribeNext:^(id x) {
        @strongify(self)
        self.inputView.inputTextView.text = @"";
        [self.viewModel.requestRemoteDataCommand execute:@1];
    }];
}


#pragma mark tableView scrollDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_inputView && scrollView == self.tableView) {
        [_inputView isAndResignFirstResponder];
    }
}

#pragma mark tableView dataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DRShotDetailCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DRShotDetailCommentTableViewCell className]];
    [cell bindViewModel:self.viewModel.dataSource[indexPath.row]];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
