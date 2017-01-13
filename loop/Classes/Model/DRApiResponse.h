//
//  DRBaseModel.h
//  
//
//  Created by Vladimir Zgonik on 18.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRObject.h"

@interface DRApiResponse : DRObject

@property (assign, nonatomic) NSInteger statusCode;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) id object;

+ (instancetype)responseWithError:(NSError *)error;
+ (instancetype)responseWithObject:(id)data;
+ (instancetype)responseWithObject:(id)data error:(NSError *)error;

@end