//
//  InAppPurchase.h
//
//  Created by Masaki Hirokawa on 13/08/29.
//  Copyright (c) 2013 Masaki Hirokawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "Reachability.h"
#import "NetworkActivityManager.h"
#import "DCActivityIndicator.h"
#import "DCDevice.h"
#import "DCUtil.h"

@protocol InAppPurchaseDelegate;

@interface InAppPurchase : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    id<InAppPurchaseDelegate> _ia_delegate;
    id                        _delegate;
    NSString                  *proccessingProductId;
    id                        rootView;
    BOOL                      isProccessing;
    BOOL                      isRestored;
}

#pragma mark - property
@property (nonatomic, assign) id<InAppPurchaseDelegate> ia_delegate;
@property (nonatomic, assign) id delegate;

#pragma mark - public method
+ (InAppPurchase *)sharedManager;
- (void)startPurchase:(NSString *)productId view:(id)view;
- (void)restorePurchase:(NSString *)productId view:(id)view;

@end

#pragma mark - delegate method
@protocol InAppPurchaseDelegate <NSObject>
@optional
- (void)InAppPurchaseDidFinish;
@end
