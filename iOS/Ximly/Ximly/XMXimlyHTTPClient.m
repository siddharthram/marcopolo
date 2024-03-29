//
//  XMXimlyHTTPClient.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMXimlyHTTPClient.h"
#import "XMAppDelegate.h"
#import "AFImageRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "XMImageCache.h"
#import "XMJob.h"
#import "XMJobList.h"
#import "XMSettingsViewController.h"
#import "SFHFKeychainUtils.h"



static NSString *_deviceID = nil;

static NSString * const kXimlyBaseURLString = @"http://default-environment-jrcyxn2kkh.elasticbeanstalk.com/";

@implementation XMXimlyHTTPClient


+ (XMXimlyHTTPClient *)sharedClient {
    static XMXimlyHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[XMXimlyHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kXimlyBaseURLString]];
    });
    
    return _sharedClient;
}

+ (NSString *)newRequestID;
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

- (void)cancelAndClean {
    [self.operationQueue cancelAllOperations];
    [self.operationQueue waitUntilAllOperationsAreFinished];
}

- (void)requestPath:(NSString *)path
             method:(NSString *)method
         parameters:(NSDictionary *)parameters
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)uploadFile:(NSData *)fileData path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure progress:(void (^)(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress {
    
    // TODO
    
}

// Override AFHTTPClient to log requests
- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    // Wrap the success block to log requests
    void (^wrappedSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef _DEBUG_
        NSLog(@"Request: %@ %@\nHeaders: %@\nBody: %@", [operation.request HTTPMethod], [operation.request URL], [operation.request allHTTPHeaderFields], [[NSString alloc] initWithData:[operation.request HTTPBody] encoding:NSASCIIStringEncoding]);
        NSLog(@"Response: %d\nHeaders: %@\nBody: %@", [operation.response statusCode],
              [operation.response allHeaderFields], responseObject);
#endif
        success(operation, responseObject);
    };
    
    // Wrap the failure block to log failures
    APIErrorBlock wrappedFailure = ^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef _DEBUG_
        NSLog(@"Request: %@ %@\nHeaders: %@\nBody: %@", [operation.request HTTPMethod], [operation.request URL], [operation.request allHTTPHeaderFields], [[NSString alloc] initWithData:[operation.request HTTPBody] encoding:NSASCIIStringEncoding]);
        NSLog(@"Response: %d\nHeaders: %@\nBody: %@\nError: %@", [operation.response statusCode], [operation.response allHeaderFields], [operation responseString], [error localizedDescription]);
#endif
        if (failure) {
            failure(operation, error);
        }
    };
    
    return [super HTTPRequestOperationWithRequest:urlRequest success:wrappedSuccess failure:wrappedFailure];
}

+ (NSString *)getErrorFromOperation:(AFHTTPRequestOperation *)operation {
    NSError *error = nil;
    NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&error];
    
    NSString *errorMessage = nil;
    
    if (!error) {
        if ([[errorDict allKeys] count] > 0) {
            NSString *errorField = [[errorDict allKeys] objectAtIndex:0];
            NSArray *errorDescriptions = [errorDict objectForKey:errorField];
            if (([errorDescriptions isKindOfClass:[NSArray class]]) && ([errorDescriptions count] > 0)) {
                NSString *errorDescription = [errorDescriptions objectAtIndex:0];
                if ([errorField isEqualToString:@"base"]) {
                    errorMessage = errorDescription;
                }
                else {
                    errorMessage = [NSString stringWithFormat:@"%@ %@", errorField, errorDescription];
                }
            }
        }
    }
    
    return errorMessage;
}


- (NSString *)getDeviceID {
    
    if ([_deviceID length] == 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _deviceID = [userDefaults stringForKey:kDeviceIDPrefKey];
        if ([_deviceID length] == 0) {
            NSError *error;
            _deviceID = [SFHFKeychainUtils getPasswordForUsername:kXMKeychainDeviceIDKey andServiceName:kXMKeychainService error:&error];
            if ([_deviceID length] == 0) {
                _deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                [SFHFKeychainUtils storeUsername:kXMKeychainDeviceIDKey andPassword:_deviceID forServiceName:kXMKeychainService updateExisting:YES error:&error];
            }
        }
    }
    return _deviceID;
}

#define kXMKeychainRegistrationKey @"kXMKeychainRegistrationKey"

+ (BOOL)isRegistered
{
    NSError *error;
    NSString *isRegisteredStr = [SFHFKeychainUtils getPasswordForUsername:kXMKeychainRegistrationKey andServiceName:kXMKeychainService error:&error];
    return isRegisteredStr && [isRegisteredStr isEqualToString:@"YES"];
}

+ (void)setIsRegistered:(BOOL)isRegistered
{
    NSError *error;
    [SFHFKeychainUtils storeUsername:kXMKeychainRegistrationKey andPassword:(isRegistered ? @"YES" : @"NO") forServiceName:kXMKeychainService updateExisting:YES error:&error];
    
}

+ (int)getImagesLeft
{
    NSError *error;
    NSString *imagesLeftString = [SFHFKeychainUtils getPasswordForUsername:kXMKeychainImagesLeftKey andServiceName:kXMKeychainService error:&error];
    
    return ([imagesLeftString length] > 0) ? [imagesLeftString intValue] : 0;
}

+ (void)setImagesLeft:(int)imagesLeft
{
    NSError *error;
    [SFHFKeychainUtils storeUsername:kXMKeychainImagesLeftKey andPassword:[NSString stringWithFormat:@"%i", imagesLeft] forServiceName:kXMKeychainService updateExisting:YES error:&error];
}



- (NSString *)getAuthID {
    return @"_";
}

- (void)updateTasks {
    [self requestPath:@"task/mine" method:@"POST" parameters:[NSDictionary dictionaryWithObject:[self getDeviceID] forKey:kJobDeviceIDKey]
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSArray *taskStatusesArray = [responseDict objectForKey:@"taskStatuses"];
        [[XMJobList sharedInstance] mergeInJobsData:taskStatusesArray];
        [[XMJobList sharedInstance] submitUnsubmittedJobs];
        NSNumber *numLeft = [responseDict objectForKey:kImagesLeft];
        [XMXimlyHTTPClient setImagesLeft:[numLeft intValue]];
        [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to get file list");
        [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
    }];
}

- (void)rateJob:(XMJob *)job {
    NSDictionary *parameters = @{kJobDeviceIDKey : [self getDeviceID],
                                 kJobServerReqeustIDKey : [job.serverRequestID length] > 0 ? job.serverRequestID : @"",
                                 kJobTranscriptionIDKey : [job.transcriptionID length] > 0 ? [NSNumber numberWithLongLong:[job.transcriptionID longLongValue]] : [NSDecimalNumber zero],
                                 kJobRatingKey : [job.rating length] > 0 ? job.rating : @"",
                                 kJobRatingCommentKey : [job.ratingComment length] > 0 ? job.ratingComment : @"",
                                 kJobUserTranscriptionKey : [job.userTranscription length] > 0 ? job.userTranscription : @""};
    [self requestPath:@"task/rate" method:@"POST" parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Failed to rate job");
                  [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
              }];
}

- (void)submitImage:(NSData *)imageData forJob:(XMJob *)theJob
{
    NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:@"task/new" parameters:[theJob submissionMetaData] constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"dummyName" fileName:@"dummyFileName" mimeType:@"image/jpeg"];
    }];
    
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSNumber *responseCode = [responseDict valueForKey:@"responseCode"];
        NSNumber *numLeft = [responseDict objectForKey:kImagesLeft];
        [XMXimlyHTTPClient setImagesLeft:[numLeft intValue]];
        if ([responseCode isEqualToNumber:[NSDecimalNumber zero]]) {
            theJob.imageURL = [responseDict valueForKey:kJobImageURLKey];
            theJob.serverRequestID = [responseDict valueForKey:kJobServerReqeustIDKey];

            [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_JOB_SUBMISSION_SUCCEEDED object:theJob];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_JOB_SUBMISSION_FAILED object:theJob];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_JOB_SUBMISSION_FAILED object:theJob];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)registerDeviceWithAPNSToken:(NSData *)token updateAPNS:(BOOL)updateAPNS delegate:(NSObject<XMXimlyHTTPClientDelegate> *)delegate
{
    NSString *apnsTokenStr = nil;
    if ([token length] > 0) {
        apnsTokenStr = [[[[token description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    } else {
        apnsTokenStr = @"";
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[[self getDeviceID], apnsTokenStr] forKeys:@[kJobDeviceIDKey, kAPNSDeviceTokenKey]];
    
    if (updateAPNS) {
        [params setObject:@"t" forKey:@"updateApns"];
    }
    
    [self requestPath:@"task/register" method:@"POST" parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [XMXimlyHTTPClient setIsRegistered:YES];
                  NSDictionary *responseDict = (NSDictionary *)responseObject;
                  NSNumber *numLeft = [responseDict objectForKey:kImagesLeft];
                  [XMXimlyHTTPClient setImagesLeft:[numLeft intValue]];
                  [delegate requestSucceeded];
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Failed to register token");
                  [delegate requestFailed];
              }];
}

- (AFImageRequestOperation *)fetchImageWithURL:(NSURL *)url
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    AFImageRequestOperation *operation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
    return operation;
}

- (void)fetchAttachmentWithURL:(NSURL *)url
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

@end
