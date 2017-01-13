//
//  DRWebViewModel.m
//  loop
//
//  Created by doom on 2016/11/23.
//  Copyright © 2016年 DOOM. All rights reserved.
//

#import "DRWebViewModel.h"

@implementation DRWebViewModel

- (instancetype)initWithService:(id <DRViewModelServices>)services andParams:(NSDictionary *)params {
    self = [super initWithService:services andParams:params];
    if (self) {
        NSString *urlString = params[@"urlString"];
        if (urlString.length > 0) {
            self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        }
    }
    return self;
}

@end
