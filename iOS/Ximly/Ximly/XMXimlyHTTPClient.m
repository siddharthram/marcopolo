//
//  XMXimlyHTTPClient.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMXimlyHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "XMImageCache.h"
#import "XMJob.h"

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
        NSLog(@"Request: %@ %@\nHeaders: %@\nBody: %@", [operation.request HTTPMethod], [operation.request URL], [operation.request allHTTPHeaderFields], [[NSString alloc] initWithData:[operation.request HTTPBody] encoding:NSASCIIStringEncoding]);
        NSLog(@"Response: %d\nHeaders: %@\nBody: %@", [operation.response statusCode],
              [operation.response allHeaderFields], responseObject);
        
        success(operation, responseObject);
    };
    
    // Wrap the failure block to log failures
    APIErrorBlock wrappedFailure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request: %@ %@\nHeaders: %@\nBody: %@", [operation.request HTTPMethod], [operation.request URL], [operation.request allHTTPHeaderFields], [[NSString alloc] initWithData:[operation.request HTTPBody] encoding:NSASCIIStringEncoding]);
        NSLog(@"Response: %d\nHeaders: %@\nBody: %@\nError: %@", [operation.response statusCode], [operation.response allHeaderFields], [operation responseString], [error localizedDescription]);
        
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
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSString *)getAuthID {
    return @"_";
}

- (void)updateTasks {
    [self requestPath:@"task/mine" method:@"POST" parameters:[NSDictionary dictionaryWithObject:[self getDeviceID] forKey:kJobDeviceIDKey]
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSArray *taskStatusesArray = [responseDict objectForKey:@"taskStatuses"];
        for (NSDictionary *taskStatus in taskStatusesArray) {
            XMJob *xmJob = [[XMJob alloc] init];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to get file list");
        [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
    }];
}


- (void)submitImage:(NSData *)imageData withMetaData:(NSDictionary *)metaData
{
    NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:@"task/new" parameters:metaData constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"dummyName" fileName:@"dummyFileName" mimeType:@"image/png"];
    }];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_JOB_SUBMISSION_SUCCEEDED object:[metaData valueForKey:kJobRequestIDKey]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_JOB_SUBMISSION_FAILED object:[metaData valueForKey:kJobRequestIDKey]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

@end
