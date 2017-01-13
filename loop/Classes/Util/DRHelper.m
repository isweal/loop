//
//  DRHelper.m
//  loop
//
//  Created by doom on 16/7/4.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRHelper.h"

void regCollectionClass(UICollectionView *collectionView, Class cellClass) {
    [collectionView registerClass:cellClass forCellWithReuseIdentifier:[cellClass className]];
}

void regTableClass(UITableView *tableView, Class cellClass) {
    [tableView registerClass:cellClass forCellReuseIdentifier:[cellClass className]];
}

void regCollectionNib(UICollectionView *collectionView, Class cellClass) {
    [collectionView registerNib:[UINib nibWithNibName:[cellClass className] bundle:nil] forCellWithReuseIdentifier:[cellClass className]];
}

void regTableNib(UITableView *tableView, Class cellClass) {
    [tableView registerNib:[UINib nibWithNibName:[cellClass className] bundle:nil] forCellReuseIdentifier:[cellClass className]];
}

void regSupplementaryClass(UICollectionView *collectionView, Class viewClass, NSString *supplementaryViewOfKind){
    [collectionView registerClass:viewClass forSupplementaryViewOfKind:supplementaryViewOfKind withReuseIdentifier:[viewClass className]];
}

void regSupplementaryNib(UICollectionView *collectionView, Class viewClass, NSString *supplementaryViewOfKind){
    [collectionView registerNib:[UINib nibWithNibName:[viewClass className] bundle:nil] forSupplementaryViewOfKind:supplementaryViewOfKind withReuseIdentifier:[viewClass className]];
}

@implementation DRHelper

+ (YYWebImageManager *)avatarImageManager {
    static YYWebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[UIApplication sharedApplication].cachesPath stringByAppendingPathComponent:@"avatar"];
        YYImageCache *cache = [[YYImageCache alloc] initWithPath:path];
        manager = [[YYWebImageManager alloc] initWithCache:cache queue:[YYWebImageManager sharedManager].queue];
        manager.sharedTransformBlock = ^(UIImage *image, NSURL *url) {
            if (!image) return image;
            return [image imageByRoundCornerRadius:10];
        };
    });
    return manager;
}

@end
