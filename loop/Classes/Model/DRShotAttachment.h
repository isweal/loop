//
//  DRShotAttachment.h
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRObject.h"

@interface DRShotAttachment : DRObject

@property (strong, nonatomic) NSNumber *attachmentId;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *thumbnail_url;
@property (strong, nonatomic) NSString *content_type;
@property (strong, nonatomic) NSNumber *size;
@property (strong, nonatomic) NSNumber *views_count;
@property (strong, nonatomic) NSString *created_at;

@end
