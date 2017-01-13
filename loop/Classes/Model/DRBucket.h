//
//  DRBucket.h
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRObject.h"
#import "DRUser.h"

@interface DRBucket : DRObject

@property(copy, nonatomic) NSString *created_at;
@property(copy, nonatomic) NSString *bucketDescription;
@property(strong, nonatomic) NSNumber *bucketId;
@property(copy, nonatomic) NSString *name;
@property(strong, nonatomic) NSNumber *shots_count;
@property(copy, nonatomic) NSString *updated_at;

@property(nonatomic, strong) DRUser *user;

@end
