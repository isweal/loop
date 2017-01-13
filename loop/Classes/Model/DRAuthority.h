//
//  DRAuthority.h
//  loop
//
//  Created by doom on 16/6/30.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRObject.h"
#import "DRLink.h"

@interface DRAuthority : DRObject

@property(nonatomic, strong) NSString *avatar_url;
@property(nonatomic, strong) NSString *bio;
@property(nonatomic, strong) NSNumber *buckets_count;
@property(nonatomic, strong) NSString *buckets_url;
@property(nonatomic, assign) BOOL can_upload_shot;
@property(nonatomic, strong) NSNumber *comments_received_count;
@property(nonatomic, strong) NSString *created_at;
@property(nonatomic, strong) NSNumber *followers_count;
@property(nonatomic, strong) NSString *followers_url;
@property(nonatomic, strong) NSString *following_url;
@property(nonatomic, strong) NSNumber *followings_count;
@property(nonatomic, strong) NSString *html_url;
@property(nonatomic, strong) NSString *likes_url;
@property(nonatomic, strong) NSNumber *likes_count;
@property(nonatomic, strong) NSNumber *likes_received_count;
@property(nonatomic, strong) NSString *location;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) BOOL pro;
@property(nonatomic, strong) NSNumber *projects_count;
@property(nonatomic, strong) NSString *projects_url;
@property(nonatomic, strong) NSNumber *rebounds_received_count;
@property(nonatomic, strong) NSNumber *members_count;
@property(nonatomic, strong) NSString *team_shots_url;
@property(nonatomic, strong) NSString *members_url;
@property(nonatomic, strong) NSNumber *shots_count;
@property(nonatomic, strong) NSString *shots_url;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *updated_at;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) DRLink *links;

@end
