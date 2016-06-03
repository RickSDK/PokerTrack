//
//  UpgradeVC.h
//  PokerTracker
//
//  Created by Rick Medved on 1/24/16.
//
//

#import "TemplateVC.h"
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

@interface UpgradeVC : TemplateVC <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) IBOutlet UIView *promoCodeView;
@property (strong, nonatomic) IBOutlet UITextField *promoCodeField;
@property (strong, nonatomic) SKProduct *proUpgradeProduct;
@property (strong, nonatomic) SKProductsRequest *productsRequest;
@property (strong, nonatomic) NSString *productID;
@property (nonatomic) int touchCount;

- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;

- (IBAction) upgradeButtonPressed: (id) sender;
- (IBAction) restoreButtonPressed: (id) sender;
- (IBAction) submitButtonPressed: (id) sender;
- (IBAction) reviewButtonPressed: (id) sender;

@end
