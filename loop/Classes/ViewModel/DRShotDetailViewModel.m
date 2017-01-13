//
//  DRShotDetailViewModel.m
//  loop
//
//  Created by doom on 16/8/16.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShotDetailViewModel.h"
#import "DRShotDetailHeaderViewModel.h"
#import "DRLoginViewModel.h"
#import "DRUserViewModel.h"
#import "DRWebViewModel.h"
#import "DRUserListViewModel.h"
#import "DRShotDetailCommentViewCellViewModel.h"

#import "DRComment.h"

#import "DRApiClient.h"
#import "DRApiResponse.h"

@interface DRShotDetailViewModel ()

@end

@implementation DRShotDetailViewModel

-(void)dealloc{
    
}

- (instancetype)initWithService:(id <DRViewModelServices>)services andParams:(NSDictionary *)params {
    self = [super initWithService:services andParams:params];
    if (self) {
        self.shot = params[@"shot"];
        self.shotId = params[@"shotId"] ?: self.shot.shotId;
    }
    return self;
}

- (void)initCommand {
    [super initCommand];

    NSAssert(self.shotId != nil, @"shotId must not be nil");

    self.shouldInfiniteScrolling = YES;
    self.shouldPullToRefresh = YES;

    @weakify(self)
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSIndexPath *indexPath) {
        @strongify(self)
        DRShotDetailCommentViewCellViewModel *commentModel = self.dataSource[indexPath.row];
        DRUserViewModel *viewModel = [[DRUserViewModel alloc] initWithService:self.services
                                                                    andParams:@{@"userId": commentModel.comment.user.userId}];
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];

    self.didClickUrlCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(DRHtmlMediaItem *htmlMediaItem) {
        @strongify(self)
        switch (htmlMediaItem.htmlMediaItemType) {
            case HtmlMediaItemType_ATUser: {
                DRUserViewModel *viewModel = [[DRUserViewModel alloc] initWithService:self.services andParams:@{@"userId": htmlMediaItem.atUserID}];
                [self.services pushViewModel:viewModel animated:YES];
                break;
            }
            case HtmlMediaItemType_WebSite: {
                DRWebViewModel *viewModel = [[DRWebViewModel alloc] initWithService:self.services andParams:@{@"urlString": htmlMediaItem.href}];
                [self.services pushViewModel:viewModel animated:YES];
                break;
            }
            case HtmlMediaItemType_Mail: {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"open the mail app?" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?subject=Hello", htmlMediaItem.href]];
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [DRSharedAppDelegate.navigationControllerStack.topNavigationController presentViewController:alert animated:YES completion:nil];
                break;
            }
            case HtmlMediaItemType_Shot: {
                DRShotDetailViewModel *viewModel = [[DRShotDetailViewModel alloc] initWithService:self.services andParams:@{@"shotId": htmlMediaItem.shotID}];
                [self.services pushViewModel:viewModel animated:YES];
                break;
            }
        }
        return [RACSignal empty];
    }];

    self.uploadCommentCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
        RACTupleUnpack(NSNumber *shotId, NSString *body) = tuple;
        return [[DRApiClient sharedClient] uploadCommentWithShot:shotId withBody:body];
    }];
    [self.uploadCommentCommand.errors subscribe:self.errors];

    self.updateCommentCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
        RACTupleUnpack(NSNumber *commentId, NSNumber *shotId, NSString *body) = tuple;
        return [[DRApiClient sharedClient] updateCommentWith:commentId forShot:shotId withBody:body];
    }];
    [self.updateCommentCommand.errors subscribe:self.errors];

    [self.requestRemoteDataCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self)
        if ([x isKindOfClass:[DRShot class]]) {
            self.shot = x;
            self.shotDetailHeaderViewModel.shot = x;
        } else {
            self.comments = x;
            self.shouldInfiniteScrolling = self.comments.count >= kDefaultShotsPerPageNumber;
        }
    }];

    self.shotDetailHeaderViewModel = [[DRShotDetailHeaderViewModel alloc] initWithShot:self.shot];
    self.shotDetailHeaderViewModel.shotImage = self.params[@"shotImage"];
    self.shotDetailHeaderViewModel.didClickUrlCommand = self.didClickUrlCommand;
    self.shotDetailHeaderViewModel.bucketCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //TODO: push bucket list
        return [RACSignal empty];
    }];
    self.shotDetailHeaderViewModel.likesCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        DRUserListViewModel *viewModel = [[DRUserListViewModel alloc] initWithService:self.services andParams:nil];
        viewModel.shotId = self.shotId;
        viewModel.userListOption = DRUserListOption_ShotLikes;
        viewModel.title = @"Likes";
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];
    self.shotDetailHeaderViewModel.checkLikeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSNumber *shotId) {
        @strongify(self)
        return [[[DRApiClient sharedClient] checkLikeWithShot:shotId] takeUntil:self.rac_willDeallocSignal];
    }];
    self.shotDetailHeaderViewModel.likeShotCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
        @strongify(self)
        RACTupleUnpack(__block NSNumber *isAuth, NSNumber *shotId, NSNumber *isLike) = tuple;
        if (isAuth.boolValue) {
            return isLike.boolValue ? [[[DRApiClient sharedClient] likeWithShot:shotId] takeUntil:self.rac_willDeallocSignal] :
                    [[[DRApiClient sharedClient] unlikeWithShot:shotId] takeUntil:self.rac_willDeallocSignal];
        } else {
            DRLoginViewModel *viewModel = [[DRLoginViewModel alloc] initWithService:self.services andParams:nil];
            [self.services presentViewModel:viewModel animated:YES completion:nil];
            @weakify(viewModel)
            return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                @strongify(viewModel)
                @weakify(subscriber)
                [viewModel.cancelCommand.executionSignals.switchToLatest.deliverOnMainThread subscribeNext:^(id x) {
                    @strongify(subscriber)
                    [subscriber sendError:nil];
                }];

                [viewModel.authSuccessSignal subscribeNext:^(NSNumber *isAuth) {
                    @strongify(subscriber)
                    if (isAuth.boolValue) {
                        [subscriber sendNext:@"auth"];
                    }
                    [subscriber sendCompleted];
                }];

                [viewModel.authCommand.errors subscribeNext:^(NSError *error) {
                    @strongify(subscriber)
                    [subscriber sendError:error];
                }];
                return (RACDisposable *) nil;
            }];
        }
    }];
    [self.shotDetailHeaderViewModel.likeShotCommand.errors subscribe:self.errors];
    self.shotDetailHeaderViewModel.userCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(DRUser *user) {
        @strongify(self)
        DRUserViewModel *viewModel = [[DRUserViewModel alloc] initWithService:self.services andParams:@{@"user": user}];
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];
    self.shotDetailHeaderViewModel.commentCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //TODO: use offset to scroll comment
        return [RACSignal empty];
    }];
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSInteger)page {
    RACSignal *commentSignal = [[[DRApiClient sharedClient] loadCommentsWithShot:self.shotId atPage:page] map:^id(DRApiResponse *apiResponse) {
        return apiResponse.object;
    }];
    RACSignal *shotSignal = (self.firstIn && self.shot != nil) ? [RACSignal empty] :
            [[[DRApiClient sharedClient] loadShotWith:self.shotId] map:^id(DRApiResponse *apiResponse) {
                return apiResponse.object;
            }];
    self.firstIn = NO;
    return [[RACSignal merge:@[commentSignal, shotSignal]] takeUntil:self.rac_willDeallocSignal];
}

#pragma mark setter

- (void)setShot:(DRShot *)shot {
    _shot = shot;
    if (_shot) {
        self.shotId = _shot.shotId;
    }
}

@end
