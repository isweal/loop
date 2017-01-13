//
//  DRShotViewModel.h
//  loop
//
//  Created by doom on 2016/11/22.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRCollectionViewModel.h"

typedef NS_ENUM(NSInteger, DRShotOption) {
    DRShotOption_loadUserLike = 0,
};

@interface DRShotViewModel : DRCollectionViewModel

@property(nonatomic, strong) NSArray *shots;
@property(nonatomic, assign) DRShotOption shotOption;

//DRShotOption_loadUserLike
@property(nonatomic, strong) DRUser *userForUserLike;

// overwrite it if you want custom define RAC(self, shots)
-(void)bindShots;

@end
