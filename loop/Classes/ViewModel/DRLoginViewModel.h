//
//  DRLoginViewModel.h
//  loop
//
//  Created by doom on 2016/9/27.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRWebViewModel.h"

@class NXOAuth2Account;

@interface DRLoginViewModel : DRWebViewModel

@property(nonatomic, strong) RACCommand *authCommand;
@property(nonatomic, strong) RACCommand *cancelCommand;

@property(nonatomic, strong) RACSignal *authSuccessSignal;

@property(copy, nonatomic) NSString *redirectUrl;

- (void)finalizeAuthWithAccount:(NXOAuth2Account *)account error:(NSError *)error;

@end
