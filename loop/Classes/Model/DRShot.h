//
//  DRShot.h
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRArtWork.h"
#import "DRImage.h"
#import "DRHtmlMedia.h"

@interface DRShot : DRArtWork

@property(nonatomic, assign) BOOL animated;
@property(strong, nonatomic) NSNumber *shotId;
@property(strong, nonatomic) NSNumber *width;
@property(strong, nonatomic) NSNumber *height;
@property(copy, nonatomic) NSString *title;

@property(copy, nonatomic) NSString *shotDescription;
@property(nonatomic, strong) DRHtmlMedia *shotshotDescriptionMedia;

@property(strong, nonatomic) NSNumber *views_count;
@property(strong, nonatomic) NSNumber *likes_count;
@property(strong, nonatomic) NSNumber *comments_count;
@property(strong, nonatomic) NSNumber *attachments_count;
@property(strong, nonatomic) DRImage *images;
@property(strong, nonatomic) NSNumber *rebounds_count;
@property(strong, nonatomic) NSNumber *buckets_count;
@property(copy, nonatomic) NSString *rebound_source_url;
@property(copy, nonatomic) NSString *html_url;
@property(copy, nonatomic) NSString *attachments_url;
@property(copy, nonatomic) NSString *buckets_url;
@property(copy, nonatomic) NSString *comments_url;
@property(copy, nonatomic) NSString *likes_url;
@property(copy, nonatomic) NSString *projects_url;
@property(copy, nonatomic) NSString *rebounds_url;
@property(strong, nonatomic) NSArray *tags;

@end
