//
//  InAppPurchase.m
//
//  Created by Masaki Hirokawa on 13/08/29.
//  Copyright (c) 2013 Masaki Hirokawa. All rights reserved.
//

#import "InAppPurchase.h"

@implementation InAppPurchase

@synthesize ia_delegate;
@synthesize delegate;

#pragma mark - Shared Manager

static InAppPurchase *_sharedInstance = nil;

+ (InAppPurchase *)sharedManager
{
    if (!_sharedInstance) {
        _sharedInstance = [[InAppPurchase alloc] init];
    }
    return _sharedInstance;
}

#pragma mark - Init

- (id)init
{
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark - In App Purchase

//アプリ内課金処理を開始
- (void)startPurchase:(NSString *)productId view:(id)view
{
    if (![self canMakePayments]) {
        // アプリ内課金が許可されていなければアラートを出して終了
        [DCUtil showAlert:nil message:NSLocalizedString(@"errorBillingLimited", nil) cancelButtonTitle:nil otherButtonTitles:@"OK"];
        return;
    } else if (![self canAccessNetwork]) {
        // ネットワークにアクセスできなければアラートを出して終了
        [DCUtil showAlert:nil message:NSLocalizedString(@"errorNetworkConnection", nil) cancelButtonTitle:nil otherButtonTitles:@"OK"];
        return;
    }
    
    // 処理中であれば処理しない
    if (isProccessing) {
        return;
    }
    
    // 処理中フラグを立てる
    isProccessing = YES;
    
    // リストアフラグ初期化
    isRestored = NO;
    
    // プロダクトID保持
    proccessingProductId = productId;
    
    // View保持
    rootView = view;
    
    // プロダクト情報の取得処理を開始
    NSSet *set = [NSSet setWithObjects:productId, nil];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // ネットワークアクセスの開始処理
    [self initNetworkAccess];
}

// デリゲートメソッド (終了通知)
- (void)requestDidFinish:(SKRequest *)request
{
    // ネットワークアクセスの終了処理
    [self quitNetworkAccess];
}

// デリゲートメソッド (アクセスエラー)
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [DCUtil showAlert:nil message:[error localizedDescription] cancelButtonTitle:nil otherButtonTitles:@"OK"];
}

// デリゲートメソッド (プロダクト情報を取得)
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // レスポンスがなければエラー処理
    if (response == nil) {
        [DCUtil showAlert:nil message:NSLocalizedString(@"errorNoResponse", nil) cancelButtonTitle:nil otherButtonTitles:@"OK"];
        return;
    }
    
    // プロダクトIDが無効な場合はアラートを出して終了
    if ([response.invalidProductIdentifiers count] > 0) {
        [DCUtil showAlert:nil message:NSLocalizedString(@"errorInvalidItemID", nil) cancelButtonTitle:nil otherButtonTitles:@"OK"];
        return;
    }
    
    // 購入処理開始
    for (SKProduct *product in response.products) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    
    // ネットワークアクセスの開始処理
    [self initNetworkAccess];
}

// 購入完了時の処理
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    // トランザクション記録
    [self recordTransaction:transaction];
    
    // アイテム付与
    [self provideContent: transaction.payment.productIdentifier];
}

// リストア完了時の処理
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    //リストアフラグを立てる
    isRestored = YES;
    
    // トランザクション記録
    [self recordTransaction:transaction];
    
    // アイテム付与
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"%@", transaction);
}

- (void)provideContent:(NSString *)productIdentifier
{
    // TODO: アイテムの付与
    
    
    
}

// デリゲートメソッド (購入処理開始後に状態が変わるごとに随時コールされる)
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
            // 購入処理中
            [DCActivityIndicator start:rootView
                                center:CGPointMake([DCDevice screenWidth] / 2, [DCDevice screenHeight] / 2)
                               styleId:2 hidesWhenStopped:YES showOverlay:YES];
        } else if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            // 購入処理成功
            [DCUtil showAlert:nil message:NSLocalizedString(@"productPurchased", nil) cancelButtonTitle:nil otherButtonTitles:@"OK"];
            
            // 該当するプロダクトのロックを解除する
            [self completeTransaction:transaction];
            
            // インジケータ非表示
            [DCActivityIndicator stop];
            
            // 処理中フラグを下ろす
            isProccessing = NO;
            
            // ペイメントキューからトランザクションを削除
            [queue finishTransaction:transaction];
            
            // ネットワークアクセスの終了処理
            [self quitNetworkAccess];
            
            return;
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            // ユーザーによるキャンセルでなければアラートを出す
            if (transaction.error.code != SKErrorPaymentCancelled) {
                // 購入処理失敗の場合はアラート表示
                [DCUtil showAlert:nil message:[transaction.error localizedDescription] cancelButtonTitle:nil otherButtonTitles:@"OK"];
            }
            
            // インジケータ非表示
            [DCActivityIndicator stop];
            
            // 処理中フラグを下ろす
            isProccessing = NO;
            
            // ペイメントキューからトランザクションを削除
            [queue finishTransaction:transaction];
            
            // ネットワークアクセスの終了処理
            [self quitNetworkAccess];
            
            return;
        } else if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            // リストア処理開始
            [DCUtil showAlert:nil message:NSLocalizedString(@"productRestored", nil) cancelButtonTitle:nil otherButtonTitles:@"OK"];
            
            // 購入済みのプロダクトのロックを再解除する
            [self restoreTransaction:transaction];
            
            // インジケータ非表示
            [DCActivityIndicator stop];
            
            // 処理中フラグを下ろす
            isProccessing = NO;
            
            // ペイメントキューからトランザクションを削除
            [queue finishTransaction:transaction];
            
            // ネットワークアクセスの終了処理
            [self quitNetworkAccess];
            
            return;
        }
    }
}

#pragma mark - Restore

- (void)restorePurchase:(NSString *)productId view:(id)view
{
    if (![self canAccessNetwork]) {
        // ネットワークにアクセスできなければアラートを出して終了
        [DCUtil showAlert:nil message:NSLocalizedString(@"errorNetworkConnection", nil) cancelButtonTitle:nil otherButtonTitles:@"OK"];
        return;
    }
    
    // 処理中であれば処理しない
    if (isProccessing) {
        return;
    }
    
    // 処理中フラグを立てる
    isProccessing = YES;
    
    // リストアフラグ初期化
    isRestored = NO;
    
    // プロダクトID保持
    proccessingProductId = productId;
    
    // View保持
    rootView = view;
    
    // 購入済みプラグインのリストア処理を開始する
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    // ネットワークアクセスの開始処理
    [self initNetworkAccess];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    // 購入済みでなかった場合アラート表示
    if (!isRestored) {
        [DCUtil showAlert:nil message:NSLocalizedString(@"errorNotRestoreItem", nil) cancelButtonTitle:nil otherButtonTitles:@"OK"];
    }
    
    // 処理中フラグを下ろす
    isProccessing = NO;
    
    // ネットワークアクセスの終了処理
    [self quitNetworkAccess];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    for (SKPaymentTransaction *transaction in queue.transactions) {
        // リストア失敗のアラート表示
        [DCUtil showAlert:nil message:NSLocalizedString(@"errorFailedRestore", nil) cancelButtonTitle:nil otherButtonTitles:@"OK"];
    }
    
    // ネットワークアクセスの終了処理
    [self quitNetworkAccess];
}

#pragma mark - Check method

// ネットワークアクセスが可能か
- (BOOL)canAccessNetwork
{
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            // 接続不可
            return NO;
            break;
        case ReachableViaWWAN:
            // 携帯回線（3Gなど）
            break;
        case ReachableViaWiFi:
            // Wi-Fi接続
            break;
        default:
            break;
    }
    return YES;
}

// アプリ内課金が許可されているか
- (BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - Network Access

// ネットワークアクセスの開始処理
- (void)initNetworkAccess
{
    [[NetworkActivityManager sharedManager] increment];
}

// ネットワークアクセスの終了処理
- (void)quitNetworkAccess
{
    [[NetworkActivityManager sharedManager] decrement];
    
    // すべての通信が終わったらデリゲートに通知する
    if (![[NetworkActivityManager sharedManager] isLoading]) {
        if ([_delegate respondsToSelector:@selector(InAppPurchaseDidFinish)]) {
            [_delegate InAppPurchaseDidFinish];
        }
    }
}

@end