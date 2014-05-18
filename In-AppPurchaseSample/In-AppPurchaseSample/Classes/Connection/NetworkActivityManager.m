//
//  NetworkActivityManager.m
//
//  Created by 三浦 英治 on 12/07/26.
//  Copyright (c) 2012年 株式会社はんぶんこ. All rights reserved.
//

#import "NetworkActivityManager.h"

@implementation NetworkActivityManager

static NetworkActivityManager*  _sharedInstance = nil;


+ (NetworkActivityManager*)sharedManager {
    if (!_sharedInstance) {
        _sharedInstance = [[NetworkActivityManager alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    activityCount = 0;
    
    return self;
}

- (void)increment {
    if(activityCount == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    activityCount++;
    
    //NSLog(@"NetworkActivityManager ++, %d", activityCount);
}

- (void)decrement {
    if(activityCount > 0) {
        activityCount--;
        
        if(activityCount == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        
        //NSLog(@"NetworkActivityManager --, %d", activityCount);
    }
}

- (BOOL)isLoading {
    if (activityCount > 0) {
        return YES;
    }
    return NO;
}

@end