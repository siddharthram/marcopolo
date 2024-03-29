//
//  XMPurchaseManager.m
//
//  Created by Young Yoo on 03/10/2013.
//

#import "XMPurchaseManager.h"
#import "SFHFKeychainUtils.h"
#import "XMXimlyHTTPClient.h"

#define kInAppPurchasePrefKey     @"InAppPurchasePrefKey"

#define kFreeStartCount     @"5"

static BOOL _observingTransactions = NO;
static XMPurchaseManager *_sharedInstance = nil;
static dispatch_once_t onceToken;

void* base64_decode(const char* s, size_t* data_len_ptr);

@interface XMPurchaseManager ()

- (void)purchaseProductWithCode:(NSString *)productCode;
- (void)submitPurchase:(NSDictionary *)purchaseData transaction:(SKPaymentTransaction *)transaction;

@end

@implementation XMPurchaseManager


+ (XMPurchaseManager *)sharedInstance {
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[XMPurchaseManager alloc] init];
    });
    
    return _sharedInstance;
}

+ (BOOL)isPurchasingEnabled
{
    return YES;
}

+ (void)setIsPurchasingEnabled:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:kInAppPurchasePrefKey];
    [userDefaults synchronize];
}

- (void)cleanup
{
    [self stopObservingTransactions];
    
    onceToken = 0;
    _sharedInstance = nil;
}

- (void)startObservingTransactions
{
    if ([XMPurchaseManager isPurchasingEnabled] && !_observingTransactions) {
        _observingTransactions = YES;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
}

- (void)stopObservingTransactions
{
    _observingTransactions = NO;
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];    
}

- (void)fetchProducts
{
    if ([XMPurchaseManager isPurchasingEnabled]) {
        self.listOfProducts = [NSMutableDictionary dictionaryWithCapacity:3];
        NSSet *productIdentifiers = [NSSet setWithObjects:kLevel1ProductCode, kLevel2ProductCode, kLevel3ProductCode,nil ];
        productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        productsRequest.delegate = self;
        [productsRequest start];
    } else {
        if ([self.delegate respondsToSelector:@selector(didFetchProducts:)]) {
            [self.delegate didFetchProducts:nil];
        }
    }
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    for (SKProduct * product in products) {
        [self.listOfProducts setObject:product forKey:product.productIdentifier];
    }
    
    if ([self.delegate respondsToSelector:@selector(didFetchProducts:)]) {
        [self.delegate didFetchProducts:self.listOfProducts];
    }
}

- (void)purchaseLevel1Product
{
    [self purchaseProductWithCode:kLevel1ProductCode];
}

- (void)purchaseLevel2Product
{
    [self purchaseProductWithCode:kLevel2ProductCode];
}

- (void)purchaseLevel3Product
{
    [self purchaseProductWithCode:kLevel3ProductCode];
}

- (void)purchaseProductWithCode:(NSString *)productCode
{
    if ([XMPurchaseManager isPurchasingEnabled]) {
        SKProduct * product = [self.listOfProducts objectForKey:productCode];
        if (product) {
            if ([SKPaymentQueue canMakePayments]) {
                [self startObservingTransactions];
                SKPayment *payment =  [SKPayment paymentWithProduct:product];
                if (payment) {
                    [[SKPaymentQueue defaultQueue] addPayment:payment];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(failedToStartPurchase)]) {
                    [self.delegate failedToStartPurchase];
                }
            }
        } else {
            // We should never reach here
            NSAssert(NO, @"Product not found in list");
            if ([self.delegate respondsToSelector:@selector(failedToStartPurchase)]) {
                [self.delegate failedToStartPurchase];
            }
        }
    } else {
        [self.delegate failedToStartPurchase];
    }
}

static int POS(char c)
{
    if (c>='A' && c<='Z') return c - 'A';
    if (c>='a' && c<='z') return c - 'a' + 26;
    if (c>='0' && c<='9') return c - '0' + 52;
    if (c == '+') return 62;
    if (c == '/') return 63;
    if (c == '=') return -1;
    
    [NSException raise:@"invalid BASE64 encoding" format:@"Invalid BASE64 encoding"];
    return 0;
}

-(NSString *)Base64Encode:(NSData *)data{
    //Point to start of the data and set buffer sizes
    int inLength = [data length];
    int outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
    const char *inputBuffer = [data bytes];
    char *outputBuffer = malloc(outLength);
    outputBuffer[outLength] = 0;
    
    //64 digit code
    static char Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    //start the count
    int cycle = 0;
    int inpos = 0;
    int outpos = 0;
    char temp;
    
    //Pad the last to bytes, the outbuffer must always be a multiple of 4
    outputBuffer[outLength-1] = '=';
    outputBuffer[outLength-2] = '=';
    
    /* http://en.wikipedia.org/wiki/Base64
     Text content   M           a           n
     ASCII          77          97          110
     8 Bit pattern  01001101    01100001    01101110
     
     6 Bit pattern  010011  010110  000101  101110
     Index          19      22      5       46
     Base64-encoded T       W       F       u
     */
    
    
    while (inpos < inLength){
        switch (cycle) {
            case 0:
                outputBuffer[outpos++] = Encode[(inputBuffer[inpos]&0xFC)>>2];
                cycle = 1;
                break;
            case 1:
                temp = (inputBuffer[inpos++]&0x03)<<4;
                outputBuffer[outpos] = Encode[temp];
                cycle = 2;
                break;
            case 2:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xF0)>> 4];
                temp = (inputBuffer[inpos++]&0x0F)<<2;
                outputBuffer[outpos] = Encode[temp];
                cycle = 3;                  
                break;
            case 3:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xC0)>>6];
                cycle = 4;
                break;
            case 4:
                outputBuffer[outpos++] = Encode[inputBuffer[inpos++]&0x3f];
                cycle = 0;
                break;                          
            default:
                cycle = 0;
                break;
        }
    }
    NSString *pictemp = [NSString stringWithUTF8String:outputBuffer];
    free(outputBuffer); 
    return pictemp;
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction
{

    
    if ([transaction transactionReceipt] != nil)
    {
#ifdef _DEBUG_
        NSLog(@"Purchase: The receipt is %@",[[NSString alloc] initWithData:[transaction transactionReceipt]
                                                         encoding:NSUTF8StringEncoding] );
#endif
        NSDictionary *receiptDict       = [self dictionaryFromPlistData:transaction.transactionReceipt];
        NSString *purchaseInfo = [receiptDict objectForKey:@"purchase-info"];
        NSString *decodedPurchaseInfo   = [self decodeBase64:purchaseInfo length:nil];
        NSDictionary *purchaseInfoDict  = [self dictionaryFromPlistData:[decodedPurchaseInfo dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *bid = [purchaseInfoDict objectForKey:@"bid"];
        
        if (![bid isEqualToString:[NSBundle mainBundle].bundleIdentifier]) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            return;
        }

        NSString *receiptData = [self Base64Encode:transaction.transactionReceipt];
        NSString *deviceID = [[XMXimlyHTTPClient sharedClient] getDeviceID];
        NSString *productID = [purchaseInfoDict objectForKey:@"product-id"];
        NSString *txnID = [purchaseInfoDict objectForKey:@"transaction-id"];
        
        NSDictionary *purchaseData = @{@"deviceId" : deviceID, @"product_id" : productID, @"transaction_id" : txnID, @"receipt_data" : receiptData};
#ifdef _DEBUG_
        NSLog(@"Purchase data:  %@", purchaseData);
#endif
        [self submitPurchase:purchaseData transaction:transaction];
    }
}

- (void)submitPurchase:(NSDictionary *)purchaseData transaction:(SKPaymentTransaction *)transaction
{
    [[XMXimlyHTTPClient sharedClient] requestPath:@"product/purchase" method:@"POST" parameters:purchaseData
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *responseDict = (NSDictionary *)responseObject;
                  NSNumber *status = [responseDict objectForKey:kImagePurchaseStatus];
                  if (status) {
                      NSNumber *numLeft = [responseDict objectForKey:kImagesLeft];
                      [XMXimlyHTTPClient setImagesLeft:[numLeft intValue]];
                      int statusCode = [status intValue];
                      switch (statusCode) {
                          case 0:
                              [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                              if ([self.delegate respondsToSelector:@selector(didProcessTransactionSuccessfully:)]) {
                                  [self.delegate didProcessTransactionSuccessfully:[numLeft intValue]];
                              }
                              break;
                          case -2:
                              // We tried to send an old receipt up to our server again
                              [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                              if ([self.delegate respondsToSelector:@selector(didProcessTransactionWithXimlyError:)]) {
                                  [self.delegate didProcessTransactionWithXimlyError:statusCode];
                              }
                              break;
                          case -1:
                          default:
                              if ([self.delegate respondsToSelector:@selector(didProcessTransactionWithXimlyError:)]) {
                                  [self.delegate didProcessTransactionWithXimlyError:statusCode];
                              }
                              break;
                      }
                  } else {
                      if ([self.delegate respondsToSelector:@selector(didProcessTransactionUnsuccessfully)]) {
                          [self.delegate didProcessTransactionUnsuccessfully];
                      }
                  }
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  if ([self.delegate respondsToSelector:@selector(didProcessTransactionUnsuccessfully)]) {
                      [self.delegate didProcessTransactionUnsuccessfully];
                  }
              }];
}



- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    if ([transaction error]) {
        NSLog(@"Purchase: failedTransaction error: %@", [transaction error]);
    }
    if ([self.delegate respondsToSelector:@selector(didProcessTransactionWithAppleError:)]) {
        [self.delegate didProcessTransactionWithAppleError:[transaction error]];
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self completeTransaction:transaction];

}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                break;
            
            case SKPaymentTransactionStatePurchased:
            {
                [self completeTransaction:transaction];
                break;
            }
                
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
                
            default:
                NSAssert(NO, @"Unknown SKPaymentTransactionState");
                break;
        }
        

    }
}

- (NSDictionary *)dictionaryFromPlistData:(NSData *)data
{
    NSError *error;
    NSDictionary *dictionaryParsed = [NSPropertyListSerialization propertyListWithData:data
                                                                               options:NSPropertyListImmutable
                                                                                format:nil
                                                                                 error:&error];
    if (!dictionaryParsed)
    {
        if (error)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
        return nil;
    }
    return dictionaryParsed;
}

void* base64_decode(const char* s, size_t* data_len_ptr)
{
    size_t len = strlen(s);
    
    if (len % 4)
        [NSException raise:@"Invalid input in base64_decode" format:@"%zd is an invalid length for an input string for BASE64 decoding", len];
    
    unsigned char* data = (unsigned char*) malloc(len/4*3);
    
    int n[4];
	memset(n,0,4*sizeof(int)); //CLANG:initialize array to zero to eliminate complaint of garbage in this array
	
    unsigned char* q = (unsigned char*) data;
    
    for(const char*p=s; *p; )
    {
        n[0] = POS(*p++);
        n[1] = POS(*p++);
        n[2] = POS(*p++);
        n[3] = POS(*p++);
        
        if (n[0]==-1 || n[1]==-1)
            [NSException raise:@"Invalid input in base64_decode" format:@"Invalid BASE64 encoding"];
        
        if (n[2]==-1 && n[3]!=-1)
            [NSException raise:@"Invalid input in base64_decode" format:@"Invalid BASE64 encoding"];
        
        q[0] = (n[0] << 2) + (n[1] >> 4);
        if (n[2] != -1) q[1] = ((n[1] & 15) << 4) + (n[2] >> 2);
        if (n[3] != -1) q[2] = ((n[2] & 3) << 6) + n[3];
        q += 3;
    }
    
    // make sure that data_len_ptr is not null
    if (!data_len_ptr)
        [NSException raise:@"Invalid input in base64_decode" format:@"Invalid destination for output string length"];
    
    *data_len_ptr = q-data - (n[2]==-1) - (n[3]==-1);
    
    return data;
}

- (NSString *)decodeBase64:(NSString *)input length:(NSInteger *)length
{
    size_t retLen;
    uint8_t *retStr = base64_decode([input UTF8String], &retLen);
    if (length)
        *length = (NSInteger)retLen;
    NSString *st = [[NSString alloc] initWithBytes:retStr
                                             length:retLen
                                           encoding:NSUTF8StringEncoding];
    free(retStr);    // If base64_decode returns dynamically allocated memory
    return st;
}


@end
