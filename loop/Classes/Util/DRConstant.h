//
//  DRConstant.h
//  loop
//
//  Created by doom on 16/8/1.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#ifndef DRConstant_h
#define DRConstant_h

/**
 *  Interface
 */

static const CGFloat kDefaultUserNameFont = 14;
static const CGFloat kDefaultContentFont = 12;

/**
 *  Color
 */

#define kDefaultBackGroundColor  UIColorHex(ffffff)
#define kDefaultLineColor  UIColorHex(dddddd)
#define kDefaultTextContentColor  UIColorHex(000000)

/**
 *  Block
 */

typedef void (^VoidBlock)();

typedef BOOL (^BoolBlock)();

typedef int  (^IntBlock)();

typedef id   (^IDBlock)();

typedef void (^VoidBlock_int)(int);

typedef BOOL (^BoolBlock_int)(int);

typedef int  (^IntBlock_int)(int);

typedef id   (^IDBlock_int)(int);

typedef void (^VoidBlock_string)(NSString *);

typedef BOOL (^BoolBlock_string)(NSString *);

typedef int  (^IntBlock_string)(NSString *);

typedef id   (^IDBlock_string)(NSString *);

typedef void (^VoidBlock_id)(id);

typedef BOOL (^BoolBlock_id)(id);

typedef int  (^IntBlock_id)(id);

typedef id   (^IDBlock_id)(id);

/**
 *  AppInfo
 */

#define DR_APP_NAME    ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"])
#define DR_APP_VERSION ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
#define DR_APP_BUILD   ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])

/**
 *  AppDelegate
 */

#define DRSharedAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

//A better version of NSLog
#define NSLog(format, ...) do {                                             \
fprintf(stderr, "<%s : %d> %s\n",                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "-------\n");                                               \
} while (0)

#ifdef DEBUG
#define DLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define DLog(format, ...)
#endif

#define BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); };

#define TrueAssign_EXEC(dic, value) if (value) { dic = value; };

#define IOS_VERSION_LOWER_THAN_8 (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)

#define kKeyWindow [UIApplication sharedApplication].keyWindow

#define kScreen_Bounds (IOS_VERSION_LOWER_THAN_8 ? (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds] : CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)) : [[UIScreen mainScreen] bounds])

#define kScreen_Width (IOS_VERSION_LOWER_THAN_8 ? (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height) : [[UIScreen mainScreen] bounds].size.width)

#define kScreen_Height (IOS_VERSION_LOWER_THAN_8 ? (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width) : [[UIScreen mainScreen] bounds].size.height)

#define kDevice_Is_iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#endif /* DRConstant_h */
