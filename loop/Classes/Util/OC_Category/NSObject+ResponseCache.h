//
//  NSObject+responseCache.h
//  loop
//
//  Created by doom on 16/8/18.
//  Copyright © 2016年 doom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ResponseCache)

+ (BOOL)saveKeyedArchiverResponseData:(id)data toPath:(NSString *)requestPath;

+ (id)loadKeyedArchiverResponseWithPath:(NSString *)requestPath;

+ (BOOL)deleteKeyedArchiverResponseCacheForPath:(NSString *)requestPath;

+ (BOOL)deleteAllKeyedArchiverResponseCache;

+ (BOOL)deleteAllKeyedArchiverCacheWithPath:(NSString *)cachePath;

@end
