//
//  DSCountDownUtil.m
//  loop
//
//  Created by doom on 2016/9/21.
//  Copyright (c) 2016 DOOM. All rights reserved.
//

#import "DSCountDownUtil.h"

@interface DSCountDownUtil ()

@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) NSInteger second;
@property(nonatomic, assign) NSInteger totalSecond;
@property(nonatomic, strong) NSDate *startDate;

@property(nonatomic, copy) CountChanging countChanging;
@property(nonatomic, copy) CountComplete countComplete;

@end

@implementation DSCountDownUtil

+ (void)startWithSecond:(NSInteger)second changing:(CountChanging)countChanging complete:(CountComplete)countComplete {
    DSCountDownUtil *countDownUtil = [DSCountDownUtil new];
    countDownUtil.countChanging = countChanging;
    countDownUtil.countComplete = countComplete;
    [countDownUtil startTimerWithSecond:second + 1];
}

- (void)startTimerWithSecond:(NSInteger)second {
    _second = second;
    _totalSecond = second;
    _startDate = [NSDate date];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)timerAction:(NSTimer *)theTimer {
    double deltaTime = [[NSDate date] timeIntervalSinceDate:_startDate];
    _second = _totalSecond - (NSInteger)(deltaTime+1) ;

    if(_second <= 0){
        [self stopCountDown];
    } else{
        BLOCK_EXEC(_countChanging, _second);
    }
}

- (void)stopCountDown{
    if(_timer){
        if([_timer respondsToSelector:@selector(isValid)]){
            if(_timer.isValid){
                [_timer invalidate];
                _second = _totalSecond;
                BLOCK_EXEC(_countComplete, _totalSecond - 1);
            }
        }
    }
}


@end
