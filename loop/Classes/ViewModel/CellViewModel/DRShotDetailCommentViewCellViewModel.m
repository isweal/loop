//
//  DRShotDetailCommentViewCellViewModel.m
//  loop
//
//  Created by doom on 16/8/23.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShotDetailCommentViewCellViewModel.h"
#import "DRComment.h"

@implementation DRShotDetailCommentViewCellViewModel

- (instancetype)initWithComment:(DRComment *)comment {
    self = [super init];
    if (self) {
        self.comment = comment;
        self.content = [self.comment.bodyMedia setupHighlight];
    }
    return self;
}


@end
