//
//  MPStore.m
//  MoPub
//
//  Created by Andrew He on 2/6/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPStore.h"
#import "MPAdView.h"
#import "MPConstants.h"

@interface MPStore (Internal)

- (void)requestProductDataForProductIdentifier:(NSString *)identifier;
- (void)startPaymentForProductIdentifier:(NSString *)identifier;
- (void)recordTransaction:(SKPaymentTransaction *)transaction;

@end

@implementation MPStore

+ (MPStore *)sharedStore
{
	static MPStore *sharedStore = nil;
	@synchronized(self)
	{
		if (sharedStore == nil)
		{
			sharedStore = [[MPStore alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:sharedStore];
		}
		return sharedStore;
	}
}

- (id)init
{
	if (self = [super init])
	{
		_isProcessing = NO;
		
		// Default to purchase quantity of 1.
		_quantity = 1;
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark -
#pragma mark Internal

- (void)requestProductDataForProductIdentifier:(NSString *)identifier
{
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:
								  [NSSet setWithObject:identifier]];
	request.delegate = self;
	[request start];
}

- (void)startPaymentForProductIdentifier:(NSString *)identifier
{
	SKMutablePayment *payment = [SKMutablePayment paymentWithProductIdentifier:identifier];
	payment.quantity = _quantity;
	[[SKPaymentQueue defaultQueue] addPayment:payment];
	_isProcessing = NO;
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction 
{
	// Report this transaction (specifically its receipt) back to the MoPub servers.
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", HOSTNAME, STORE_RECEIPT_SUFFIX]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	NSString *receiptString = [[[NSString alloc] initWithData:transaction.transactionReceipt 
													 encoding:NSUTF8StringEncoding] autorelease];
	NSString *postBody = [NSString stringWithFormat:@"udid=%@&receipt=%@", 
						  [[UIDevice currentDevice] hashedMoPubUDID],
						  [receiptString URLEncodedString]];
	NSString *msgLength = [NSString stringWithFormat:@"%d", [postBody length]];
	[request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -

- (void)initiatePurchaseForProductIdentifier:(NSString *)identifier quantity:(NSInteger)quantity
{
	if (_isProcessing)
	{
		MPLogWarn(@"Warning - MPStore (%p) can only initiate one store request at a time.", self);
		return;
	}
	
	_isProcessing = YES;
	_quantity = quantity;
	[self requestProductDataForProductIdentifier:identifier];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[request autorelease];
	SKProduct *product = [response.products objectAtIndex:0];
	[self startPaymentForProductIdentifier:product.productIdentifier];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	[request autorelease];
	MPLogError(@"SKProductsRequest failed with error %@.", error);
	_isProcessing = NO;
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	// We only care about recording completed transactions.
    for (SKPaymentTransaction *transaction in transactions)
    {
        if (transaction.transactionState == SKPaymentTransactionStatePurchased)
        {
			[self recordTransaction:transaction];
        }
    }
}

@end
