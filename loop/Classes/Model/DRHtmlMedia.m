//
//  DRHtmlMedia.m
//  loop
//
//  Created by doom on 16/8/24.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRHtmlMedia.h"
#import "OCGumbo+Query.h"
#import "RegExCategories.h"

NSString *const kDRHtmlMediaItemName = @"kDRHtmlMediaItemName";

@implementation DRHtmlMediaItem

+ (instancetype)itemWithType:(HtmlMediaItemType)htmlMediaItemType {
    DRHtmlMediaItem *htmlMediaItem = [DRHtmlMediaItem new];
    htmlMediaItem.htmlMediaItemType = htmlMediaItemType;
    return htmlMediaItem;
}

@end

@implementation DRHtmlMedia

- (instancetype)initWithString:(NSString *)htmlString {
    self = [super init];
    if (self) {
        if (htmlString.length <= 0) {
            return self;
        }

        _mediaItems = [[NSMutableArray alloc] init];
        DLog(@"html : %@", htmlString);
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
                    [_mediaItems addObject:htmlMediaItem];
                } else if ( (match = [href firstMatch:RX(@"(?<=dribble.com/shots/)\\d+")]) ){
                    // shot
                    DRHtmlMediaItem *htmlMediaItem = [DRHtmlMediaItem itemWithType:HtmlMediaItemType_Shot];
                    htmlMediaItem.shotID = match.numberValue;
                    htmlMediaItem.range = [temp rangeOfString:linkText];
                    [_mediaItems addObject:htmlMediaItem];
                } else if ([href hasPrefix:@"mailto"]){
                    // mail
                    DRHtmlMediaItem *htmlMediaItem = [DRHtmlMediaItem itemWithType:HtmlMediaItemType_Mail];
                    htmlMediaItem.href = href;
                    htmlMediaItem.range = [temp rangeOfString:linkText];
                    [_mediaItems addObject:htmlMediaItem];
                } else if ([link.attr(@"rel") containsString:@"noreferrer"]){
                    // webSite
                    DRHtmlMediaItem *htmlMediaItem = [DRHtmlMediaItem itemWithType:HtmlMediaItemType_WebSite];
                    htmlMediaItem.href = href;
                    htmlMediaItem.range = [temp rangeOfString:linkText];
                    [_mediaItems addObject:htmlMediaItem];
                }
            }
        }];
        _contentDisplay = [[NSMutableAttributedString alloc] initWithString:temp];
        // 不能在此设置YYTextHighlight, 无法archive, 会引起崩溃
    }
    return self;
}

- (NSAttributedString *)setupHighlight {
    NSMutableAttributedString *content = self.contentDisplay.mutableCopy;
    for (DRHtmlMediaItem *htmlMediaItem in self.mediaItems) {
        YYTextHighlight *highlight = [YYTextHighlight highlightWithBackgroundColor:[UIColor colorWithHexString:@"0xdcdcdc"]];
        highlight.userInfo = @{kDRHtmlMediaItemName: htmlMediaItem};
        [content setTextHighlight:highlight range:htmlMediaItem.range];
        
        switch (htmlMediaItem.htmlMediaItemType) {
            case HtmlMediaItemType_ATUser:
                [content setColor:[UIColor colorWithHexString:@"0x29acf6"] range:htmlMediaItem.range];
                break;
                
            case HtmlMediaItemType_WebSite:
                [content setColor:[UIColor colorWithHexString:@"0x29acf6"] range:htmlMediaItem.range];
                break;

            case HtmlMediaItemType_Mail:
                [content setColor:[UIColor colorWithHexString:@"0x29acf6"] range:htmlMediaItem.range];
                break;
                
            case HtmlMediaItemType_Shot:
                [content setColor:[UIColor colorWithHexString:@"0x29acf6"] range:htmlMediaItem.range];
                break;
        }
    }
    return content.copy;
}


@end
