//
//  UpgradeVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/24/16.
//
//

#import "UpgradeVC.h"
#import "MainMenuVC.h"

@interface UpgradeVC ()

@end

@implementation UpgradeVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Upgrade!"];

	self.productID = [NSString new];
	self.productID = @"proVersionPTP";

	self.promoCodeView.hidden=YES;
}

- (IBAction) promoCodeButtonPressed: (id) sender {
	self.promoCodeView.hidden=!self.promoCodeView.hidden;
}

- (IBAction) submitButtonPressed: (id) sender {
	[self.promoCodeField resignFirstResponder];
	if(self.promoCodeField.text.length==0)
		[ProjectFunctions showAlertPopup:@"Error" message:@"Invalid Promo Code"];
	else
		[self startWebService:@selector(submitPromoCode) message:nil];
}

-(void)submitPromoCode {
	@autoreleasepool {
		NSString *webAddr = @"http://www.appdigity.com/poker/promoCode.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:[NSArray arrayWithObject:@"promoCode"] valueList:[NSArray arrayWithObject:self.promoCodeField.text]];
		NSLog(@"+++%@", responseStr);
		if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
			[self unlockUpgrade];
		}
		
		[self stopWebService];
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	MainMenuVC *detailViewController = [[MainMenuVC alloc] initWithNibName:@"MainMenuVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}



- (IBAction) upgradeButtonPressed: (id) sender {
	[self startWebService:@selector(loadStore) message:nil];
}
- (IBAction) restoreButtonPressed: (id) sender {
	[self startWebService:@selector(loadStore) message:nil];
}


- (void)loadStore
{
	// restarts any purchases if they were interrupted last time the app was open
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	
	// get the product description (defined in early sections)
	[self requestProUpgradeProductData];
}


- (void)requestProUpgradeProductData
{
	NSSet *productIdentifiers = [NSSet setWithObject:self.productID];
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	request.delegate = self;
	[request start];
	
	self.productsRequest = request; // <<<--- This will retain the request object
	
	// we will release the request object in the delegate callback
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	NSArray *products = response.products;
	self.proUpgradeProduct = [products count] == 1 ? [products firstObject] : nil;
	if (self.proUpgradeProduct)
	{
		NSLog(@"Product title: %@" , self.proUpgradeProduct.localizedTitle);
		NSLog(@"Product description: %@" , self.proUpgradeProduct.localizedDescription);
		NSLog(@"Product price: %@" , self.proUpgradeProduct.price);
		NSLog(@"Product id: %@" , self.proUpgradeProduct.productIdentifier);
	}
	
	for (NSString *invalidProductId in response.invalidProductIdentifiers)
	{
		NSLog(@"Invalid product id: %@" , invalidProductId);
		[self.webServiceView stop];
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
	
	if([self canMakePurchases])
		[self purchaseProUpgrade];
}


-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	NSLog(@"didFailWithError: %@",error.description);
	[ProjectFunctions showAlertPopup:@"Error" message:@"Cannot connect to iTunes Store. Contact app admin."];
	_productsRequest = nil; // <<<--- This will release the request object
	[self.webServiceView stop];
}



//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
	NSLog(@"+++canMakePurchases");
	return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProUpgrade
{
	NSLog(@"+++purchaseProUpgrade");
	SKPayment *payment = [SKPayment paymentWithProduct:self.proUpgradeProduct];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
	NSLog(@"+++recordTransaction");
	if ([transaction.payment.productIdentifier isEqualToString:self.productID])
	{
		// save the transaction receipt to disk
		[[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
	NSLog(@"+++provideContent");
	if ([productId isEqualToString:self.productID])
	{
		// enable the pro features
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
	NSLog(@"+++finishTransaction");
	// remove the transaction from the payment queue.
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	[self.webServiceView stop];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
	if (wasSuccessful)
	{
		// send out a notification that we’ve finished the transaction
		[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
		[self unlockUpgrade];
	}
	else
	{
		// send out a notification for the failed transaction
		[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
	}
}

-(void)unlockUpgrade {
	[ProjectFunctions setUserDefaultValue:@"Y" forKey:@"proVersion"];
	[ProjectFunctions showAlertPopupWithDelegate:@"Thank you!" message:@"You are now a Gold Member!" delegate:self];
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
	NSLog(@"+++completeTransaction");
	[self recordTransaction:transaction];
	[self provideContent:transaction.payment.productIdentifier];
	[self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
	[self recordTransaction:transaction.originalTransaction];
	[self provideContent:transaction.originalTransaction.payment.productIdentifier];
	[self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
	NSLog(@"+++failedTransaction");
	if (transaction.error.code != SKErrorPaymentCancelled)
	{
		// error!
		[self finishTransaction:transaction wasSuccessful:NO];
		NSLog(@"+++error");
	}
	else
	{
		// this is fine, the user just cancelled, so don’t notify
		[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
		[self stopWebService];
		NSLog(@"+++stop");
	}
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	NSLog(@"+++paymentQueue");
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				[self completeTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
				[self restoreTransaction:transaction];
				break;
			default:
				break;
		}
	}
}




@end
