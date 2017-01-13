//
//  DRShotCategoryTimeFrame.h
//  loop
//
//  Created by doom on 16/7/6.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DRShotCategoryTimeFrameType) {
    DRShotCategoryTimeFrameNow = 0,
    DRShotCategoryTimeFrameWeek,
    DRShotCategoryTimeFrameMonth,
    DRShotCategoryTimeFrameYear,
    DRShotCategoryTimeFrameEver
};

@interface DRShotCategoryTimeFrame : NSObject

@property(copy, nonatomic) NSString *categoryValue;
@property(copy, nonatomic) NSString *categoryName;
@property(nonatomic, assign) DRShotCategoryTimeFrameType categoryType;

// accessors

+ (NSArray *)allCategoriesNames;

+ (NSMutableArray *)allCategories;

+ (DRShotCategoryTimeFrame *)categoryWithType:(DRShotCategoryTimeFrameType)categoryType;

@end
