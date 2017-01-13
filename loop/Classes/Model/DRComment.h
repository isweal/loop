//
//  DRComment.h
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRObject.h"
#import "DRUser.h"
#import "DRTeam.h"
#import "DRHtmlMedia.h"

@interface DRComment : DRObject

@property(strong, nonatomic) NSNumber *commentId;
@property(strong, nonatomic) NSNumber *likes_count;

@property(copy, nonatomic) NSString *body;
@property(strong, nonatomic) DRHtmlMedia *bodyMedia;

@property(copy, nonatomic) NSString *likes_url;

@property(copy, nonatomic) NSString *created_at;
@property(copy, nonatomic) NSString *createdTime;

@property(copy, nonatomic) NSString *updated_at;
@property(strong, nonatomic) DRUser *user;
@property(strong, nonatomic) DRTeam *team;

@end
