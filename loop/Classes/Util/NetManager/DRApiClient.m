//
//  DRApiClient.m
//  loop
//
//  Created by doom on 16/6/24.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRApiClient.h"
#import "DRApiClientSettings.h"
#import "DROAuthManager.h"
#import "NXOAuth2.h"
#import "DRAuthConstants.h"

#import "DRModel.h"

#import "JDStatusBarNotification.h"

static NSString *const kIDMOAuth2AuthorizationURL = @"https://dribbble.com/oauth/authorize";
static NSString *const kIDMOAuth2TokenURL = @"https://dribbble.com/oauth/token";

static NSString *const kBaseApiUrl = @"https://api.dribbble.com/v1/";

static NSString *kHttpMethodGet = @"GET";
static NSString *kHttpMethodPost = @"POST";
static NSString *kHttpMethodPut = @"PUT";
static NSString *kHttpMethodDelete = @"DELETE";

static NSString *const kAuthorizationHTTPFieldName = @"Authorization";
static NSString *const kBearerString = @"Bearer";
static NSString *const kUploadImageSizeAssertionString = @"Your file must be exatly 400x300 or 800x600";
static NSString *const kUploadFileSizeAssertionString = @"Your file must be no larger than eight megabytes";

@interface DRApiClient ()

@property(nonatomic, strong, readwrite) DRApiClientSettings *settings;
@property(nonatomic, strong) NSString *accessToken;
@property(nonatomic, strong) DROAuthManager *oauthManager;

@property(nonatomic, assign, readwrite) BOOL userAuthorized;

@end


@implementation DRApiClient

static DRApiClient *_sharedClient = nil;
static dispatch_once_t onceToken;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.oauthManager = [[DROAuthManager alloc] init];
        self.settings = [[DRApiClientSettings alloc] initWithBaseUrl:kBaseApiUrl
                                                   oAuth2RedirectUrl:kIDMOAuth2RedirectURL
                                              oAuth2AuthorizationUrl:kIDMOAuth2AuthorizationURL
                                                      oAuth2TokenUrl:kIDMOAuth2TokenURL
                                                            clientId:kIDMOAuth2ClientId
                                                        clientSecret:kIDMOAuth2ClientSecret
                                                   clientAccessToken:kIDMOAuth2ClientAccessToken
                                                              scopes:[NSSet setWithObjects:kDRPublicScope, kDRWriteScope, kDRUploadScope, kDRCommentScope, nil]];
        [self restoreAccessToken];
        if (!_accessToken) {
            [self resetAccessToken];
        }
    }
    return self;
}

+ (DRApiClient *)sharedClient {
    dispatch_once(&onceToken, ^{
        _sharedClient = [[DRApiClient alloc] init];
    });
    return _sharedClient;
}

#pragma mark - Authorization

- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
    [self.apiManager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@", kBearerString, self.accessToken] forHTTPHeaderField:kAuthorizationHTTPFieldName];
}

// use client access secret while no access token retrieved
// also call this method on logout
- (void)resetAccessToken {
    self.accessToken = self.settings.clientAccessToken;
}

- (void)restoreAccessToken {
    NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kIDMOAccountType] lastObject];
    if (account) {
        self.accessToken = account.accessToken.accessToken;
    }
}

- (BOOL)isUserAuthorized {
    return [self.accessToken length] && ![self.accessToken isEqualToString:self.settings.clientAccessToken];
}

#pragma mark - OAuth calls

- (void)authWithAccessToken:(NSString *)accessToken {
    if (accessToken.length > 0) {
        self.accessToken = accessToken;
        self.userAuthorized = YES;
    } else {
        [self resetAccessToken];
    }
}

- (void)logout {
    [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kIDMOAccountType] enumerateObjectsUsingBlock:^(NXOAuth2Account *obj, NSUInteger idx, BOOL *stop) {
        [[NXOAuth2AccountStore sharedStore] removeAccount:obj];
    }];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [self resetAccessToken];
    self.userAuthorized = NO;
    [DRRouter sharedInstance].user = nil;
}

#pragma mark - Setup

- (AFHTTPSessionManager *)apiManager {
    if (!_apiManager) {
        _apiManager = [AFHTTPSessionManager manager];
        [_apiManager.requestSerializer setHTTPShouldHandleCookies:YES];
        _apiManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _apiManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        _apiManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _apiManager.requestSerializer.timeoutInterval = 20;
    }
    return _apiManager;
}

- (RACSignal *)createSignalRequestWithMethod:(NSString *)method requestType:(NSString *)requestType modelClass:(Class)modelClass params:(NSDictionary *)params {
    @weakify(self)
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        DLog(@"%@ params -> %@", method, params);
        NSMutableURLRequest *request = [self.apiManager.requestSerializer requestWithMethod:requestType
                                                                                  URLString:[[NSURL URLWithString:method relativeToURL:[NSURL URLWithString:self.settings.baseUrl]] absoluteString]
                                                                                 parameters:params error:nil];
        NSURLSessionDataTask *task = [self.apiManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error == nil) {
                DRApiResponse *apiResponse = [self mappedDataFromResponseObject:responseObject modelClass:modelClass];
                apiResponse.statusCode = ((NSHTTPURLResponse *) response).statusCode;
                [subscriber sendNext:apiResponse];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        [task resume];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] replayLazily];
}

- (void)runMultiPartRequestWithMethod:(NSString *)method parameterName:(NSString *)paramaterName params:(NSDictionary *)params fileName:(NSString *)fileName data:(NSData *)data mimeType:(NSString *)mimeType responseHandler:(DRResponseHandler)responseHandler {
//    __weak typeof(self) weakSelf = self;
    [self.apiManager POST:method parameters:params constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:paramaterName fileName:fileName mimeType:mimeType];
    }            progress:^(NSProgress *uploadProgress) {

    }             success:^(NSURLSessionDataTask *task, id responseObject) {
        BLOCK_EXEC(responseHandler, [DRApiResponse responseWithObject:responseObject]);
    }             failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) task.response;

        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if (statusCode == kHttpRequestFailedErrorCode) {
            NSDictionary *userInfo = @{kDRUploadErrorFailureKey: error.userInfo[NSLocalizedDescriptionKey] ?: @"", NSUnderlyingErrorKey: error};
            NSError *userError = [[NSError alloc] initWithDomain:kDRUploadErrorFailureKey code:kHttpRequestFailedErrorCode userInfo:userInfo];
            error = userError;
        }
        BLOCK_EXEC(responseHandler, [DRApiResponse responseWithError:error]);
    }];
}

#pragma mark - Data response mapping

- (DRApiResponse *)mappedDataFromResponseObject:(id)object modelClass:(Class)modelClass {
    if (modelClass == [NSNull class]) {
        return [DRApiResponse responseWithObject:object];
    }
    id mappedObject;
    if ([object isKindOfClass:[NSArray class]]) {
        mappedObject = [NSArray modelArrayWithClass:modelClass json:object];
    } else {
        mappedObject = [modelClass modelWithJSON:object];
    }
    return [DRApiResponse responseWithObject:mappedObject];
}

#pragma mark - API CALLS

#pragma mark - User

- (RACSignal *)loadUserInfo {
    return [self createSignalRequestWithMethod:kDRApiMethodUser requestType:kHttpMethodGet modelClass:[DRUser class] params:nil];
}

- (RACSignal *)loadAccountWithUser:(NSNumber *)userId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserInfo, userId] requestType:kHttpMethodGet modelClass:[DRUser class]
                                        params:nil];
}

- (RACSignal *)loadLikesWithUser:(NSNumber *)userId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserLikes, userId] requestType:kHttpMethodGet
                                    modelClass:[DRTransactionModel class] params:params];
}

- (RACSignal *)loadMyLikesWithParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:kDRApiMethodMyLikes requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params];
}

- (RACSignal *)loadProjectsWithUser:(NSNumber *)userId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserProjects, userId] requestType:kHttpMethodGet modelClass:[DRProject
            class]                      params:params];
}

- (RACSignal *)loadMyProjectsWithParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:kDRApiMethodOwnUserProjects requestType:kHttpMethodGet modelClass:[DRProject class] params:params];
}

- (RACSignal *)loadTeamsWithUser:(NSNumber *)userId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserTeams, userId] requestType:kHttpMethodGet modelClass:[DRTeam class] params:params];

}

- (RACSignal *)loadMyTeamsWithParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:kDRApiMethodMyTeams requestType:kHttpMethodGet modelClass:[DRTeam class] params:params];
}

- (RACSignal *)loadFollowersWithUser:(NSNumber *)userId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodGetFollowers, userId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params];
}

- (RACSignal *)loadMyFollowersWithParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:kDRApiMethodGetMyFollowers requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params];
}

- (RACSignal *)loadFolloweesWithUser:(NSNumber *)userId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodGetFollowees, userId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params];
}

- (RACSignal *)loadMyFolloweesWithParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:kDRApiMethodGetMyFollowees requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params];
}

- (RACSignal *)loadFolloweesShotsWithParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:kDRApiMethodGetFolloweesShot requestType:kHttpMethodGet modelClass:[DRShot class] params:params];
}

#pragma mark - Shots

- (void)uploadShotWithParams:(NSDictionary *)params file:(NSData *)file fileName:(NSString *)fileName mimeType:(NSString *)mimeType responseHandler:
        (DRResponseHandler)responseHandler {
    UIImage *image = [[UIImage alloc] initWithData:file];
    CGSize imageSize = image.size;
    NSAssert((imageSize.width == 400.f && imageSize.height == 300.f) || (imageSize.width == 800.f && imageSize.height == 600.f), kUploadImageSizeAssertionString);
    NSAssert((file.length / 1024.f / 1024.f) <= kUploadFileBytesLimitSize, kUploadFileSizeAssertionString);
//    [self runMultiPartRequestWithMethod:kDRApiMethodShots parameterName:kDRParamImage params:params fileName:fileName data:file mimeType:mimeType];
}

- (RACSignal *)updateShot:(NSNumber *)shotId withParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShot, shotId] requestType:kHttpMethodPut modelClass:[DRShot class] params:params];
}

- (RACSignal *)deleteShot:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShot, shotId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil];
}

- (RACSignal *)loadShotsWithParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:kDRApiMethodShots requestType:kHttpMethodGet modelClass:[DRShot class] params:params];
}

- (RACSignal *)loadShotsFromCategory:(DRShotCategory *)category timeFrame:(DRShotCategoryTimeFrame *)timeFrame atPage:(NSInteger)page {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (category) {
        if ([category.categoryValue isEqualToString:@"recent"]) {
            dict[kDRParamSort] = category.categoryValue;
        } else if (![category.categoryValue isEqualToString:@"popular"]) {
            dict[kDRParamList] = category.categoryValue;
        }
    }
    if (page > 0) {
        dict[kDRParamPage] = @(page);
        dict[kDRParamPerPage] = @(kDefaultShotsPerPageNumber);
    }

    if (timeFrame && timeFrame.categoryValue.length > 0) {
        dict[kDRParamTimeFrame] = timeFrame.categoryValue;
    }

    return [self loadShotsWithParams:dict];
}

- (RACSignal *)loadShotsWithUser:(NSNumber *)userId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserShots, userId] requestType:kHttpMethodGet modelClass:[DRShot class] params:params];
}

- (RACSignal *)loadMyShotsWithParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:kDRApiMethodOwnUserShots requestType:kHttpMethodGet modelClass:[DRShot class] params:params];
}

- (RACSignal *)loadUserShots:(NSString *)url params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:url requestType:kHttpMethodGet modelClass:[DRShot class] params:params];
}

- (RACSignal *)loadReboundsWithShot:(NSNumber *)shotId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotRebounds, shotId] requestType:kHttpMethodGet modelClass:[DRShot class] params:params];
}

- (RACSignal *)loadShotWith:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShot, shotId] requestType:kHttpMethodGet modelClass:[DRShot class] params:nil];
}

- (RACSignal *)likeWithShot:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLikeShot, shotId] requestType:kHttpMethodPost modelClass:[DRTransactionModel class] params:nil];
}

- (RACSignal *)unlikeWithShot:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLikeShot, shotId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil];
}

- (RACSignal *)checkLikeWithShot:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckShotWasLiked, shotId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:nil];
}

- (RACSignal *)loadLikesWithShot:(NSNumber *)shotId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotLikes, shotId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params];
}

#pragma mark - Comments

- (RACSignal *)uploadCommentWithShot:(NSNumber *)shotId withBody:(NSString *)body {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotComments, shotId] requestType:kHttpMethodPost modelClass:[DRComment class] params:@{kDRParamBody: body}];
}

- (RACSignal *)updateCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId withBody:(NSString *)body {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodEditComment, shotId, commentId] requestType:kHttpMethodPut modelClass:[DRComment class] params:@{kDRParamBody: body}];
}

- (RACSignal *)deleteCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodComment, shotId, commentId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil];
}

- (RACSignal *)loadCommentsWithShot:(NSNumber *)shotId atPage:(NSInteger)page {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (page > 0) {
        dict[kDRParamPage] = @(page);
        dict[kDRParamPerPage] = @(kDefaultShotsPerPageNumber);
    }
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotComments, shotId] requestType:kHttpMethodGet
                                    modelClass:[DRComment class]
                                        params:dict];
}

- (RACSignal *)loadCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodComment, shotId, commentId] requestType:kHttpMethodGet modelClass:[DRComment class] params:nil];
}

- (RACSignal *)loadLikesWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCommentLikes, shotId, commentId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:nil];
}

- (RACSignal *)checkLikeWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckLikeComment, shotId, commentId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:nil];
}

- (RACSignal *)likeWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckLikeComment, shotId, commentId] requestType:kHttpMethodPost modelClass:[DRTransactionModel class] params:nil];
}

- (RACSignal *)unlikeWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckLikeComment, shotId, commentId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil];
}

#pragma mark - Attachments

- (void)uploadAttachmentWithShot:(NSNumber *)shotId params:(NSDictionary *)params file:(NSData *)file fileName:(NSString *)fileName mimeType:(NSString *)
        mimeType {
//    [self runMultiPartRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotAttachments, shotId] parameterName:kDRParamFile params:params fileName:fileName data:file mimeType:mimeType];
}

- (RACSignal *)deleteAttachmentWith:(NSNumber *)attachmentId forShot:(NSNumber *)shotId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodAttachment, shotId, attachmentId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil];
}

- (RACSignal *)loadAttachmentsWithShot:(NSNumber *)shotId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotAttachments, shotId] requestType:kHttpMethodGet modelClass:[DRShotAttachment class] params:nil];
}

- (RACSignal *)loadAttachmentWith:(NSNumber *)attachmentId forShot:(NSNumber *)shotId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodAttachment, shotId, attachmentId] requestType:kHttpMethodGet modelClass:[DRShotAttachment class] params:nil];
}

#pragma mark - Projects

- (RACSignal *)loadProjectsWithShot:(NSNumber *)shotId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotProjects, shotId] requestType:kHttpMethodGet modelClass:[DRProject class] params:params];
}

- (RACSignal *)loadProjectWith:(NSNumber *)projectId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodProject, projectId] requestType:kHttpMethodGet modelClass:[DRProject class] params:nil];
}

- (RACSignal *)loadProjectShotsWith:(NSNumber *)projectId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodProjectShots, projectId] requestType:kHttpMethodGet modelClass:[DRShot class] params:nil];
}

#pragma mark - Team

- (RACSignal *)loadMembersWithTeam:(NSNumber *)teamId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodTeamMembers, teamId] requestType:kHttpMethodGet modelClass:[DRUser class] params:nil];
}

- (RACSignal *)loadShotsWithTeam:(NSNumber *)teamId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodTeamShots, teamId] requestType:kHttpMethodGet modelClass:[DRShot class] params:nil];
}

#pragma mark - Following

- (RACSignal *)followUserWith:(NSNumber *)userId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodFollowUser, userId] requestType:kHttpMethodPut modelClass:[DRApiResponse class] params:nil];
}

- (RACSignal *)unFollowUserWith:(NSNumber *)userId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodFollowUser, userId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil];
}

- (RACSignal *)checkFollowingWithUser:(NSNumber *)userId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckIfUserFollowing, userId] requestType:kHttpMethodGet modelClass:[DRApiResponse class] params:nil];
}

- (RACSignal *)checkIfUserWith:(NSNumber *)userId followingAnotherUserWith:(NSNumber *)anotherUserId {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckIfOneUserFollowingAnother, userId, anotherUserId] requestType:kHttpMethodGet modelClass:[DRApiResponse class] params:nil];
}

#pragma mark - Buckets

- (RACSignal *)loadMyBucketsWithParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:kDRApiMethodMyBuckets requestType:kHttpMethodGet modelClass:[DRBucket class] params:params];
}

- (RACSignal *)loadBucketsWithUser:(NSNumber *)userId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserBuckets, userId] requestType:kHttpMethodGet modelClass:[DRBucket class] params:params];
}

- (RACSignal *)loadBucketsForShot:(NSNumber *)shotId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodBucketsForShot, shotId] requestType:kHttpMethodGet modelClass:[DRBucket class] params:params];
}

- (RACSignal *)loadBucket:(NSNumber *)bucketId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucket, bucketId] requestType:kHttpMethodGet modelClass:[DRBucket class] params:params];
}

- (RACSignal *)loadBucketShots:(NSNumber *)bucketId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucketShots, bucketId] requestType:kHttpMethodGet modelClass:[DRShot class] params:params];
}

- (RACSignal *)addShotToBucket:(NSNumber *)bucketId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucketShots, bucketId] requestType:kHttpMethodPut modelClass:[DRApiResponse class] params:params];
}

- (RACSignal *)deleteShotFromBucket:(NSNumber *)bucketId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucketShots, bucketId] requestType:kHttpMethodDelete modelClass:[DRApiResponse
            class]                      params:params];
}

- (RACSignal *)addBucketWithParams:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:kDRApiMethodAddBucket requestType:kHttpMethodPost modelClass:[DRBucket class] params:params];
}

- (RACSignal *)updateBucket:(NSNumber *)bucketId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucket, bucketId] requestType:kHttpMethodPut modelClass:[DRBucket class]
                                        params:params];
}

- (RACSignal *)deleteBucket:(NSNumber *)bucketId params:(NSDictionary *)params {
    return [self createSignalRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucket, bucketId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class]
                                        params:params];
}


@end
