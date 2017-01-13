//
//  DRShotDetailCommentViewCellViewModel.h
//  loop
//
//  Created by doom on 16/8/23.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRComment;

@interface DRShotDetailCommentViewCellViewModel : NSObject

@property(nonatomic, strong) DRComment *comment;
@property(nonatomic, copy) NSAttributedString *content;
@property(nonatomic, strong) RACCommand *didClickUrlCommand;

- (instancetype)initWithComment:(DRComment *)comment;

@end
