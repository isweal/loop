//
//  DRHelper.h
//  loop
//
//  Created by doom on 16/7/4.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

void regCollectionClass(UICollectionView *collectionView, Class cellClass);

void regTableClass(UITableView *tableView, Class cellClass);

void regCollectionNib(UICollectionView *collectionView, Class cellClass);

void regTableNib(UITableView *tableView, Class cellClass);

void regSupplementaryClass(UICollectionView *collectionView, Class viewClass, NSString *supplementaryViewOfKind);

void regSupplementaryNib(UICollectionView *collectionView, Class viewClass, NSString *supplementaryViewOfKind);

@interface DRHelper : NSObject

+ (YYWebImageManager *)avatarImageManager;

@end
