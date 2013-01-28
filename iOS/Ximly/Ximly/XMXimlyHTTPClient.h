//
//  XMXimlyHTTPClient.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "AFHTTPClient.h"

#define XM_NOTIFICATION_JOB_SUBMITTED               @"XM_NOTIFICATION_JOB_SUBMITTED"
#define XM_NOTIFICATION_JOB_SUBMISSION_SUCCEEDED    @"XM_NOTIFICATION_JOB_SUBMISSION_SUCCEEDED"
#define XM_NOTIFICATION_JOB_SUBMISSION_FAILED       @"XM_NOTIFICATION_JOB_SUBMISSION_FAILED"


@class XMJob;

typedef void (^APIErrorBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface XMXimlyHTTPClient : AFHTTPClient

+ (XMXimlyHTTPClient *)sharedClient;

+ (NSString *)newRequestID;

- (void)cancelAndClean;

// Request a path just like getPath, postPath, etc. but allows you to specify the HTTP verb as a parameter.
- (void)requestPath:(NSString *)path method:(NSString *)method parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)uploadFile:(NSData *)fileData path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure progress:(void (^)(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress;

+ (NSString *)getErrorFromOperation:(AFHTTPRequestOperation *)operation;

- (NSString *)getDeviceID;
- (NSString *)getAuthID;
- (void)updateTasks;

- (void)submitImage:(NSData *)imageData withMetaData:(NSDictionary *)metaData;

@end
