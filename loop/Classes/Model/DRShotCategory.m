//
//  DRShotCategory.m
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRShotCategory.h"

@implementation DRShotCategory

#pragma mark - Generating

+ (DRShotCategory *)createCategoryWithName:(NSString *)name value:(NSString *)value type:(DRShotCategoryType)type {
    DRShotCategory *category = [DRShotCategory new];
    category.categoryName = name;
    category.categoryType = type;
    category.categoryValue = value;
    return category;
}

+ (NSArray *)allCategoriesNames {
    return @[@"Popular", @"Recent", @"Debuts", @"Attachments", @"Playoffs", @"Animated", @"Rebounds", @"Teams"];
}

+ (NSArray *)allCategoriesValues {
    return @[@"popular", @"recent", @"debuts", @"attachments", @"playoffs", @"animated", @"rebounds", @"teams"];
}

+ (NSArray *)allCategoriesTypes {
    return @[@(DRShotCategoryPopular), @(DRShotCategoryRecent), @(DRShotCategoryDebuts), @(DRShotCategoryAttachments), @(DRShotCategoryPlayoffs), @(DRShotCategoryAnimated), @(DRShotCategoryRebounds), @(DRShotCategoryTeams)];
}

#pragma mark - Accessors

+ (NSMutableArray *)allCategories {
    static dispatch_once_t once;
    static NSMutableArray *categories;
    dispatch_once(&once, ^{
        categories = [NSMutableArray array];
        [[DRShotCategory allCategoriesTypes] enumerateObjectsUsingBlock:^(NSNumber *type, NSUInteger idx, BOOL *stop) {
            [categories addObject:[DRShotCategory createCategoryWithName:[DRShotCategory allCategoriesNames][idx] value:[DRShotCategory allCategoriesValues][idx] type:[type integerValue]]];
        }];
    });
    return categories;
}

+ (DRShotCategory *)categoryWithType:(DRShotCategoryType)categoryType {
    for (DRShotCategory *category in [DRShotCategory allCategories]) {
        if (category.categoryType == categoryType) return category;
    }
    return nil;
}


@end
