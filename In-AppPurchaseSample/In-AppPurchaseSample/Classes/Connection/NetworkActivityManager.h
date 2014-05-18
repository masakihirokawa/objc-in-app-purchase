//
//  NetworkActivityManager.h
//
//  Created by 三浦 英治 on 12/07/26.
//  Copyright (c) 2012年 株式会社はんぶんこ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkActivityManager : NSObject {
    
    NSUInteger activityCount;
}

+ (NetworkActivityManager*)sharedManager;

- (void)increment;
- (void)decrement;
- (BOOL)isLoading;

@end