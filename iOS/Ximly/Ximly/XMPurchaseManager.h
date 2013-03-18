//
//  XMPurchaseManager.h
//
//  Created by Young-Kyu Yoo on 03/10/2013.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#define kLevel1ProductCode  @"com.ximly.product.level1.01"
#define kLevel2ProductCode  @"com.ximly.product.level2.01"
#define kLevel3ProductCode  @"com.ximly.product.level3.01"

#define kXMKeychainFreeTranscriptionCount @"XMKeychainFreeTranscriptionCount"
#define kXMKeychainPaidTranscriptionCount @"XMKeychainPaidTranscriptionCount"

@protocol XMPurchaseManagerDelegate

@optional
- (void)didFetchProducts:(NSDictionary *)products;
- (void)failedToStartPurchase;
- (void)didProcessTransactionSuccessfully;
- (void)didProcessTransactionUnsuccessfully;
- (void)didProcessTransactionWithAppleError:(NSError *)error;
@end

@interface XMPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProductsRequest *productsRequest;
}

@property (nonatomic, weak) NSObject<XMPurchaseManagerDelegate> *delegate;
@property (nonatomic, strong) NSMutableDictionary * listOfProducts;

+ (XMPurchaseManager *)sharedInstance;

- (BOOL)isPurchasingEnabled;

+ (int)transcriptionsRemaining;
+ (int)freeTranscriptionsRemaining;
+ (int)paidTranscriptionsRemaining;
+ (int)modifyFreeTranscriptionsRemaining:(int)increment;
+ (int)modifyPaidTranscriptionsRemaining:(int)increment;


- (void)startObservingTransactions;
- (void)stopObservingTransactions;
- (void)fetchProducts;

- (void)purchaseLevel1Product;
- (void)purchaseLevel2Product;
- (void)purchaseLevel3Product;

@end
