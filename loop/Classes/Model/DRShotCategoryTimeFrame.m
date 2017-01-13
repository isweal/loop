//
//  DRShotCategoryTimeFrame.m
//  loop
//
//  Created by doom on 16/7/6.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShotCategoryTimeFrame.h"

@implementation DRShotCategoryTimeFrame

#pragma mark - Generating

+ (DRShotCategoryTimeFrame *)createCategoryWithName:(NSString *)name value:(NSString *)value type:(DRShotCategoryTimeFrameType)type {
    DRShotCategoryTimeFrame *category = [DRShotCategoryTimeFrame new];
    category.categoryName = name;
    category.categoryType = type;
    category.categoryValue = value;
    return category;
}

+ (NSArray *)allCategoriesNames {
    return @[@"Now", @"Week", @"Month", @"Year", @"Ever"];
}

+ (NSArray *)allCategoriesValues {
    return @[@"", @"week", @"month", @"year", @"ever"];
}

+ (NSArray *)allCategoriesTypes {
    return @[@(DRShotCategoryTimeFrameNow), @(DRShotCategoryTimeFrameWeek), @(DRShotCategoryTimeFrameMonth), @(DRShotCategoryTimeFrameYear), @
    (DRShotCategoryTimeFrameEver)];
}

#pragma mark - Accessors

+ (NSMutableArray *)allCategories {
    static dispatch_once_t once;
    static NSMutableArray *categories;
    dispatch_once(&once, ^{
        categories = [NSMutableArray array];
        [[DRShotCategoryTimeFrame allCategoriesTypes] enumerateObjectsUsingBlock:^(NSNumber *type, NSUInteger idx, BOOL *stop) {
            [categories addObject:[DRShotCategoryTimeFrame createCategoryWithName:[DRShotCategoryTimeFrame allCategoriesNames][idx] value:[DRShotCategoryTimeFrame allCategoriesValues][idx] type:[type integerValue]]];
        }];
    });
    return categories;
}

+ (DRShotCategoryTimeFrame *)categoryWithType:(DRShotCategoryTimeFrameType)categoryType {
    for (DRShotCategoryTimeFrame *category in [DRShotCategoryTimeFrame allCategories]) {
        if (category.categoryType == categoryType) return category;
    }
    return nil;
}


@end
