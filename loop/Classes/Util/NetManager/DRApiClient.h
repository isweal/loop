//
//  DRApiClient.h
//  loop
//
//  Created by doom on 16/6/24.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "DRDefinitions.h"

@class DRApiClientSettings, DRShotCategory, DRShotCategoryTimeFrame;

@interface DRApiClient : NSObject

@property(strong, nonatomic, readonly) DRApiClientSettings *settings;
@property(assign, nonatomic, readonly, getter=isUserAuthorized) BOOL userAuthorized;
@property(strong, nonatomic) AFHTTPSessionManager *apiManager;

+ (DRApiClient *)sharedClient;

#pragma mark - Auth

- (RACSignal *)authorizeWithWebView:(UIWebView *)webView;

#pragma mark - API methods

// rest

- (RACSignal *)loadUserInfo;

- (RACSignal *)loadAccountWithUser:(NSNumber *)userId;

- (RACSignal *)loadLikesWithUser:(NSNumber *)userId params:(NSDictionary *)params;

- (RACSignal *)loadMyLikesWithParams:(NSDictionary *)params;

- (RACSignal *)loadProjectsWithUser:(NSNumber *)userId params:(NSDictionary *)params;

- (RACSignal *)loadMyProjectsWithParams:(NSDictionary *)params;

- (RACSignal *)loadTeamsWithUser:(NSNumber *)userId params:(NSDictionary *)params;

- (RACSignal *)loadMyTeamsWithParams:(NSDictionary *)params;

- (RACSignal *)loadShotsWithUser:(NSNumber *)userId params:(NSDictionary *)params;

- (RACSignal *)loadMyShotsWithParams:(NSDictionary *)params;

- (RACSignal *)loadFollowersWithUser:(NSNumber *)userId params:(NSDictionary *)params;

- (RACSignal *)loadMyFollowersWithParams:(NSDictionary *)params;

- (RACSignal *)loadFolloweesWithUser:(NSNumber *)userId params:(NSDictionary *)params;

- (RACSignal *)loadMyFolloweesWithParams:(NSDictionary *)params;

- (RACSignal *)loadFolloweesShotsWithParams:(NSDictionary *)params;

// shots

- (void)uploadShotWithParams:(NSDictionary *)params file:(NSData *)file fileName:(NSString *)fileName mimeType:(NSString *)mimeType responseHandler:
        (DRResponseHandler)responseHandler;

- (RACSignal *)updateShot:(NSNumber *)shotId withParams:(NSDictionary *)params;

- (RACSignal *)deleteShot:(NSNumber *)shotId;

- (RACSignal *)loadShotWith:(NSNumber *)shotId;

- (RACSignal *)loadShotsWithParams:(NSDictionary *)params;

- (RACSignal *)loadShotsFromCategory:(DRShotCategory *)category timeFrame:(DRShotCategoryTimeFrame *)timeFrame atPage:(NSInteger)page;

- (RACSignal *)loadUserShots:(NSString *)url params:(NSDictionary *)params;

- (RACSignal *)loadReboundsWithShot:(NSNumber *)shotId params:(NSDictionary *)params;

- (RACSignal *)likeWithShot:(NSNumber *)shotId;

- (RACSignal *)unlikeWithShot:(NSNumber *)shotId;

- (RACSignal *)checkLikeWithShot:(NSNumber *)shotId;

- (RACSignal *)loadLikesWithShot:(NSNumber *)shotId params:(NSDictionary *)params;

// comments

- (RACSignal *)uploadCommentWithShot:(NSNumber *)shotId withBody:(NSString *)body;

- (RACSignal *)updateCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId withBody:(NSString *)body;

- (RACSignal *)deleteCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId;

- (RACSignal *)loadCommentsWithShot:(NSNumber *)shotId atPage:(NSInteger)page;

- (RACSignal *)loadCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId;

- (RACSignal *)likeWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId;

- (RACSignal *)unlikeWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId;

- (RACSignal *)checkLikeWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId;

- (RACSignal *)loadLikesWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId params:(NSDictionary *)params;

// attachments

- (void)uploadAttachmentWithShot:(NSNumber *)shotId params:(NSDictionary *)params file:(NSData *)file fileName:(NSString *)fileName mimeType:(NSString *)
        mimeType;

- (RACSignal *)deleteAttachmentWith:(NSNumber *)attachmentId forShot:(NSNumber *)shotId;

- (RACSignal *)loadAttachmentsWithShot:(NSNumber *)shotId params:(NSDictionary *)params;

- (RACSignal *)loadAttachmentWith:(NSNumber *)attachmentId forShot:(NSNumber *)shotId params:(NSDictionary *)params;

// projects

- (RACSignal *)loadProjectsWithShot:(NSNumber *)shotId params:(NSDictionary *)params;

- (RACSignal *)loadProjectWith:(NSNumber *)projectId;

- (RACSignal *)loadProjectShotsWith:(NSNumber *)projectId;

// following

- (RACSignal *)followUserWith:(NSNumber *)userId;

- (RACSignal *)unFollowUserWith:(NSNumber *)userId;

- (RACSignal *)checkFollowingWithUser:(NSNumber *)userId;

- (RACSignal *)checkIfUserWith:(NSNumber *)userId followingAnotherUserWith:(NSNumber *)anotherUserId;

// team

- (RACSignal *)loadMembersWithTeam:(NSNumber *)teamId params:(NSDictionary *)params;

- (RACSignal *)loadShotsWithTeam:(NSNumber *)teamId params:(NSDictionary *)params;

// bucket

- (RACSignal *)loadMyBucketsWithParams:(NSDictionary *)params;

- (RACSignal *)loadBucketsWithUser:(NSNumber *)userId params:(NSDictionary *)params;

- (RACSignal *)loadBucketsForShot:(NSNumber *)shotId params:(NSDictionary *)params;

- (RACSignal *)loadBucket:(NSNumber *)bucketId params:(NSDictionary *)params;

- (RACSignal *)loadBucketShots:(NSNumber *)bucketId params:(NSDictionary *)params;

- (RACSignal *)addShotToBucket:(NSNumber *)bucketId params:(NSDictionary *)params;

- (RACSignal *)deleteShotFromBucket:(NSNumber *)bucketId params:(NSDictionary *)params;

- (RACSignal *)addBucketWithParams:(NSDictionary *)params;

- (RACSignal *)updateBucket:(NSNumber *)bucketId params:(NSDictionary *)params;

- (RACSignal *)deleteBucket:(NSNumber *)bucketId params:(NSDictionary *)params;

- (void)logout;

@end
