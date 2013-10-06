//
//  XMPurchaseManager.h
//
//  Created by Young-Kyu Yoo on 03/10/2013.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#define kLevel1ProductCode  @"com.ximly.small.test"
#define kLevel2ProductCode  @"com.ximly.medium.test"
#define kLevel3ProductCode  @"com.ximly.large.test"

#define kXMKeychainFreeTranscriptionCount @"XMKeychainFreeTranscriptionCount"
#define kXMKeychainPaidTranscriptionCount @"XMKeychainPaidTranscriptionCount"

@protocol XMPurchaseManagerDelegate

@optional
- (void)didFetchProducts:(NSDictionary *)products;
- (void)failedToStartPurchase;
- (void)didProcessTransactionSuccessfully:(int)numPurchased;
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

+ (BOOL)isPurchasingEnabled;
+ (void)setIsPurchasingEnabled:(BOOL)value;
+ (int)transcriptionsRemaining;
+ (int)freeTranscriptionsRemaining;
+ (int)paidTranscriptionsRemaining;
+ (int)modifyFreeTranscriptionsRemaining:(int)increment;
+ (int)modifyPaidTranscriptionsRemaining:(int)increment;
+ (void)deleteTranscriptionCounts;

- (void)startObservingTransactions;
- (void)stopObservingTransactions;
- (void)fetchProducts;

- (void)purchaseLevel1Product;
- (void)purchaseLevel2Product;
- (void)purchaseLevel3Product;

@end
