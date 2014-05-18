//
//  ViewController.m
//  In-AppPurchaseSample
//
//  Created by Dolice on 2014/05/18.
//  Copyright (c) 2014年 Dolice. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSString *const PRODUCT_ID = @"com.exsample.In-AppPurchaseSample.productId";

typedef NS_ENUM(NSUInteger, upgradeEventId) {
    IAP_PURCHASE = 0,
    IAP_RESTORE  = 1
};

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

#pragma mark - Purchase / Restore

// アップグレードアイテムの購入／リストア
- (void)upgradeEvent:(UIButton *)button
{
    NSUInteger eventId = button.tag;
    InAppPurchase *inAppPurchase = [[InAppPurchase alloc] init];
    if (eventId == IAP_PURCHASE) {
        // アップグレードアイテム購入処理
        [inAppPurchase startPurchase:PRODUCT_ID view:self.view];
    } else if (eventId == IAP_RESTORE) {
        // アップグレードアイテムリストア処理
        [inAppPurchase restorePurchase:PRODUCT_ID view:self.view];
    }
}

@end
