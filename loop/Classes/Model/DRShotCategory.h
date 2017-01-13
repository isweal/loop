//
//  DRShotCategory.h
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DRShotCategoryType) {
    DRShotCategoryPopular = 0,
    DRShotCategoryRecent,
    DRShotCategoryDebuts,
    DRShotCategoryAttachments,
    DRShotCategoryPlayoffs,
    DRShotCategoryAnimated,
    DRShotCategoryRebounds,
    DRShotCategoryTeams,
};

@interface DRShotCategory : NSObject

@property(copy, nonatomic) NSString *categoryValue;
@property(copy, nonatomic) NSString *categoryName;
@property(nonatomic, assign) DRShotCategoryType categoryType;

// accessors

+ (NSArray *)allCategoriesNames;

+ (NSMutableArray *)allCategories;

+ (DRShotCategory *)categoryWithType:(DRShotCategoryType)categoryType;

@end
