//
//  DRUserListViewCellViewModel.h
//  loop
//
//  Created by doom on 2016/11/21.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRUserListViewCellViewModel : NSObject

@property(nonatomic, strong) DRUser *user;

- (instancetype)initWithUser:(DRUser *)user;

@end
