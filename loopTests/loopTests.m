//
//  loopTests.m
//  loopTests
//
//  Created by doom on 16/6/24.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DRApiClient.h"
#import "OCGumbo+Query.h"
#import "RegExCategories.h"

#import "DRHtmlMedia.h"

#define kDefaultUserID @(597558)
#define kDefaultShotID @(2807234)
#define kDefaultBucketID @(375617)
#define kDefaultProjectID @(332342)

@interface loopTests : XCTestCase


@end

@implementation loopTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRequestAppInfoFromAppStoreWithAppID {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [[[DRApiClient sharedClient] loadShotWith:kDefaultShotID]
     subscribeNext:^(id x) {
         [expectation fulfill];
     } error:^(NSError *error) {
         
     }completed:^{
         
     }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testGumboProcess {
    NSString *htmlString = @"<p>Facebook is looking for artists to create sticker packs! Interested? Email your art portfolio and contact information to <a href=\"mailto:stickers@fb.com\" rel=\"noreferrer\">stickers@fb.com</a>. Please include “Stickers Art Submission” in the subject line.</p>\n<p>No. 7!</p>\n\n<p><a href=\"http://www.10x2016.com\" rel=\"noreferrer\">www.10x2016.com</a></p>";
    NSMutableArray *mediaItems = [[NSMutableArray alloc] init];
    
    NSMutableString *temp = [[NSMutableString alloc] initWithString:@""];
    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
    
    NSArray *nodeArray = document.Query(@"p");
    [nodeArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        OCGumboNode *body = obj;
        [temp appendString:body.text()];

        if (nodeArray.count > 1 && idx < nodeArray.count - 1) {
            [temp appendString:@"\n"];
        }
        
        for (OCGumboNode *link in body.Query(@"a")) {
            NSString *linkText = link.text();
            NSString *href = link.attr(@"href");
            
            NSString *match;
            if ( (match = [href firstMatch:RX(@"(?<=dribbble.com/)\\d+")]) ) {
                // user
                DRHtmlMediaItem *htmlMediaItem = [DRHtmlMediaItem itemWithType:HtmlMediaItemType_ATUser];
                htmlMediaItem.atUserID = match.numberValue;
                htmlMediaItem.atUserName = linkText;
                htmlMediaItem.range = [temp rangeOfString:linkText];
                [mediaItems addObject:htmlMediaItem];
            } else if ( (match = [href firstMatch:RX(@"(?<=dribble.com/shots/)\\d+")]) ){
                // shot
                DRHtmlMediaItem *htmlMediaItem = [DRHtmlMediaItem itemWithType:HtmlMediaItemType_Shot];
                htmlMediaItem.shotID = match.numberValue;
                htmlMediaItem.range = [temp rangeOfString:linkText];
                [mediaItems addObject:htmlMediaItem];
            } else if ([href hasPrefix:@"mailto"]){
                // mail
                DRHtmlMediaItem *htmlMediaItem = [DRHtmlMediaItem itemWithType:HtmlMediaItemType_Mail];
                htmlMediaItem.href = href;
                htmlMediaItem.range = [temp rangeOfString:linkText];
                [mediaItems addObject:htmlMediaItem];
            } else if ([link.attr(@"rel") containsString:@"noreferrer"]){
                // webSite
                DRHtmlMediaItem *htmlMediaItem = [DRHtmlMediaItem itemWithType:HtmlMediaItemType_WebSite];
                htmlMediaItem.href = href;
                htmlMediaItem.range = [temp rangeOfString:linkText];
                [mediaItems addObject:htmlMediaItem];
            }
        }
    }];
    XCTAssert(mediaItems.count > 0, @"can't get items");
}

- (void)testRegExMatch {
    BOOL isMatch = [@"https://dribble.com/shots/2345" isMatch:RX(@"(?<=dribble.com/shots/)\\d+")];
    XCTAssertTrue(isMatch);
}

- (void)testRegExMatchs {
    NSString *matchs = [@"https://dribble.com/shots/2345" firstMatch:RX(@"(?<=dribble.com/shots/)\\d+")];
    XCTAssertTrue(matchs);
}


@end
