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

CGFloat   const BTN_WIDTH  = 184;
CGFloat   const BTN_HEIGHT = 38;
NSString *const PRODUCT_ID = @"com.exsample.In-AppPurchaseSample.productId";

typedef NS_ENUM(NSUInteger, upgradeEventId) {
    IAP_PURCHASE = 0,
    IAP_RESTORE  = 1
};

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // 購入ボタン配置
    [self setPurchaseButton];
    
    // リストアボタン配置
    [self setRestoreButton];
}

#pragma mark - Purchase / Restore

// 購入ボタン配置
- (void)setPurchaseButton
{
    CGFloat  purchaseButtonX = roundf(([DCDevice screenWidth] / 2) - (BTN_WIDTH / 2));
    CGFloat  purchaseButtonY = roundf(([DCDevice screenHeight] / 3) - (BTN_HEIGHT / 2));
    UIButton *purchaseButton = [DCButton imageButton:CGRectMake(purchaseButtonX, purchaseButtonY, BTN_WIDTH, BTN_HEIGHT)
                                                 img:[DCImage getUIImageFromResources:@"button_purchase" ext:@"png"] isHighlighte:YES
                                              on_img:[DCImage getUIImageFromResources:@"button_purchase_o" ext:@"png"]
                                            delegate:self action:@selector(upgradeEvent:) tag:IAP_PURCHASE];
    [self.view addSubview:purchaseButton];
}

// リストアボタン配置
- (void)setRestoreButton
{
    CGFloat  restoreButtonX = roundf(([DCDevice screenWidth] / 2) - (BTN_WIDTH / 2));
    CGFloat  restoreButtonY = roundf((([DCDevice screenHeight] * 2) / 3) - (BTN_HEIGHT / 2));
    UIButton *restoreButton = [DCButton imageButton:CGRectMake(restoreButtonX, restoreButtonY, BTN_WIDTH, BTN_HEIGHT)
                                                 img:[DCImage getUIImageFromResources:@"button_restore" ext:@"png"] isHighlighte:YES
                                              on_img:[DCImage getUIImageFromResources:@"button_restore_o" ext:@"png"]
                                            delegate:self action:@selector(upgradeEvent:) tag:IAP_RESTORE];
    [self.view addSubview:restoreButton];
}

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
