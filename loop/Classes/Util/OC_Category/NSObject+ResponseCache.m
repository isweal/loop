//
//  NSObject+common.m
//  loop
//
//  Created by doom on 16/8/18.
//  Copyright © 2016年 doom. All rights reserved.
//

#import "NSObject+ResponseCache.h"

#define kPath_ResponseCache @"ResponseCache"

@implementation NSObject (ResponseCache)

#pragma mark - data keyedArchiver save & load

+ (BOOL)saveKeyedArchiverResponseData:(id)data toPath:(NSString *)requestPath {
    if ([self createDirInCache:kPath_ResponseCache]) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", [self pathInCacheDirectory:kPath_ResponseCache], [requestPath md5String]];
        return [NSKeyedArchiver archiveRootObject:data toFile:path];
    } else {
        return NO;
    }
}

+ (id)loadKeyedArchiverResponseWithPath:(NSString *)requestPath {
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self pathInCacheDirectory:kPath_ResponseCache], [requestPath md5String]];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}


+ (BOOL)deleteKeyedArchiverResponseCacheForPath:(NSString *)requestPath {
    NSString *abslutePath = [NSString stringWithFormat:@"%@/%@", [self pathInCacheDirectory:kPath_ResponseCache], [requestPath md5String]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:abslutePath]) {
        return [fileManager removeItemAtPath:abslutePath error:nil];
    } else {
        return NO;
    }
}

+ (BOOL)deleteAllKeyedArchiverResponseCache {
    // it will also delete the userCache
    return [self deleteAllKeyedArchiverCacheWithPath:kPath_ResponseCache];
}

+ (BOOL)deleteAllKeyedArchiverCacheWithPath:(NSString *)cachePath {
    NSString *dirPath = [self pathInCacheDirectory:cachePath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    bool isDeleted = false;
    if (isDir && existed) {
        isDeleted = [fileManager removeItemAtPath:dirPath error:nil];
    }
    return isDeleted;
}

#pragma mark File M

+ (NSString *)pathInCacheDirectory:(NSString *)fileName {
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = cachePaths[0];
    return [cachePath stringByAppendingPathComponent:fileName];
}

+ (BOOL)createDirInCache:(NSString *)dirName {
    NSString *dirPath = [self pathInCacheDirectory:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    BOOL isCreated = NO;
    if (!(isDir && existed)) {
        isCreated = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        isCreated = YES;
    }
    return isCreated;
}

@end
