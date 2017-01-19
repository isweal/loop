//
//  DRLoginViewModel.h
//  loop
//
//  Created by doom on 2016/9/27.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DRWebViewModel.h"

@interface DRLoginViewModel : DRWebViewModel <UIWebViewDelegate>

@property(nonatomic, strong) RACCommand *authCommand;
@property(nonatomic, strong) RACCommand *cancelCommand;

@property(nonatomic, strong) RACSignal *authSuccessSignal;

@end
