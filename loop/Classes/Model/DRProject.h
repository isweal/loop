//
//  DRProject.h
//  loop
//
//  Created by doom on 16/6/29.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRArtWork.h"

@interface DRProject : DRArtWork

@property (strong, nonatomic) NSNumber *projectId;
@property (strong, nonatomic) NSString *projectDescription;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *shots_count;

@end
