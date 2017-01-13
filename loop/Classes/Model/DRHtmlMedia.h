//
//  DRHtmlMedia.h
//  loop
//
//  Created by doom on 16/8/24.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRObject.h"

extern NSString *const kDRHtmlMediaItemName;

typedef NS_ENUM(NSInteger, HtmlMediaItemType) {
    HtmlMediaItemType_ATUser,
    HtmlMediaItemType_Shot,
    HtmlMediaItemType_WebSite,
    HtmlMediaItemType_Mail
};

@interface DRHtmlMediaItem : DRObject

+ (instancetype)itemWithType:(HtmlMediaItemType)htmlMediaItemType;

@property(nonatomic, assign) HtmlMediaItemType htmlMediaItemType;

//public
@property(nonatomic, assign) NSRange range;

//HtmlMediaItemType_ATUser
@property(nonatomic, copy) NSNumber *atUserID;
@property(nonatomic, copy) NSString *atUserName; //with @

//HtmlMediaItemType_Shot
@property(nonatomic, copy) NSNumber *shotID;

//HtmlMediaItemType_Link，HtmlMediaItemType_Mail
@property(nonatomic, copy) NSString *href;

@end;

@interface DRHtmlMedia : DRObject

@property(nonatomic, strong) NSMutableAttributedString *contentDisplay;
@property(nonatomic, strong) NSMutableArray<DRHtmlMediaItem *> *mediaItems;

- (instancetype)initWithString:(NSString *)htmlString;

- (NSAttributedString *)setupHighlight;

@end
