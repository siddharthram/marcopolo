//
//  XMJob.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/26/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMJob.h"

#import "XMImageCache.h"
#import "XMXimlyHTTPClient.h"
#import "AFImageRequestOperation.h"

#define kNumberOfFields 11

@implementation XMJob 

@dynamic requestID;
@dynamic serverRequestID;
@dynamic title;
@dynamic transcription;
@dynamic status;
@dynamic submissionTime;
@dynamic serverSubmissionTime;
@dynamic transcriptionTime;
@dynamic rating;
@dynamic ratingComment;
@dynamic imageURL;
@dynamic imageKey;
@dynamic image;
@dynamic thumbnailKey;
@dynamic thumbnail;
@dynamic durationSinceLastAction;


- (id)init
{
    self = [super init];
    if (self) {
        self.jobData = [NSMutableDictionary dictionaryWithCapacity:kNumberOfFields];
    }
    return self;
}

- (NSString *)requestID
{
    return [self.jobData valueForKey:kJobRequestIDKey];
}

- (void)setRequestID:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobRequestIDKey];
}

- (NSString *)serverRequestID
{
    return [self.jobData valueForKey:kJobServerReqeustIDKey];
}

- (void)setServerRequestID:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobServerReqeustIDKey];
}

- (NSString *)title
{
    return [self.jobData valueForKey:kJobTitleKey];
}

- (void)setTitle:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobTitleKey];
}

- (NSString *)transcription
{
    return [self.jobData valueForKey:kJobTranscriptionKey];
}

- (void)setTranscription:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobTranscriptionKey];
}

- (NSString *)status
{
    NSString *statusStr = kJobStatusNoneString;
    NSNumber *status = [self.jobData valueForKey:kJobStatusKey];
    
    if (status) {
        switch ([status intValue]) {
            case JobStatusProcessing:
                statusStr = kJobStatusProcessingString;
                break;
                
            case JobStatusTranscribed:
                statusStr = kJobStatusTranscribedString;
                break;
                
            default:
                statusStr = kJobStatusNoneString;
                break;
        }
    }

    return statusStr;
}

- (void)setStatus:(NSString *)value
{
    NSNumber *newStatus = nil;
    
    if ([value isEqualToString:kJobStatusProcessingString]) {
        newStatus = [NSNumber numberWithInt:JobStatusProcessing];
    } else if ([value isEqualToString:kJobStatusTranscribedString]) {
        newStatus = [NSNumber numberWithInt:JobStatusTranscribed];
    }
    
    [self.jobData setValue:newStatus forKey:kJobStatusKey];
}

- (NSDate *)submissionTime
{
    double timeInMs = [self submissionTimeInMs];
    if (timeInMs != 0) {
        return [NSDate dateWithTimeIntervalSince1970:timeInMs/1000];
    } else {
        return nil;
    }
}

- (void)setSubmissionTime:(NSDate *)value
{
    long long timeInMs = (long long)[value timeIntervalSince1970] * 1000;
    [self.jobData setValue:[NSNumber numberWithLongLong:timeInMs] forKey:kJobSubmissionTimeKey];
}

- (double)submissionTimeInMs
{
    NSNumber *timeNum = [self.jobData valueForKey:kJobSubmissionTimeKey];
    return [timeNum doubleValue];
}

- (NSDate *)serverSubmissionTime
{
    double timeInMs = [self serverSubmissionTimeInMs];
    if (timeInMs != 0) {
        return [NSDate dateWithTimeIntervalSince1970:timeInMs/1000];
    } else {
        return nil;
    }
}

- (void)setServerSubmissionTime:(NSDate *)value
{
    long long timeInMs = (long long)[value timeIntervalSince1970] * 1000;
    [self.jobData setValue:[NSNumber numberWithLongLong:timeInMs] forKey:kJobServerSubmissionTimeKey];
}

- (double)serverSubmissionTimeInMs
{
    NSNumber *timeNum = [self.jobData valueForKey:kJobServerSubmissionTimeKey];
    return [timeNum doubleValue];
}

- (NSDate *)transcriptionTime
{
    double timeInMs = [self transcriptionTimeInMs];
    if (timeInMs != 0) {
        return [NSDate dateWithTimeIntervalSince1970:timeInMs/1000];
    }
    return nil;
}

- (void)setTranscriptionTime:(NSDate *)value
{
    long long timeInMs = (long long)[value timeIntervalSince1970] * 1000;
    [self.jobData setValue:[NSNumber numberWithLongLong:timeInMs] forKey:kJobTranscriptionTimeKey];
}

- (double)transcriptionTimeInMs
{
    NSNumber *timeNum = [self.jobData valueForKey:kJobTranscriptionTimeKey];
    return [timeNum doubleValue];
}

- (NSString *)rating
{
    return [self.jobData valueForKey:kJobRatingKey];
}

- (void)setRating:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobRatingKey];
}

- (NSString *)ratingComment
{
    return [self.jobData valueForKey:kJobRatingCommentKey];
}

- (void)setRatingComment:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobRatingCommentKey];
}

- (int)urgency
{
    NSString *urgencyString = [self.jobData valueForKey:kJobUrgencyKey];
    return [urgencyString intValue];
}

- (void)setUrgency:(int)value
{
    [self.jobData setValue:[NSString stringWithFormat:@"%d", value] forKey:kJobUrgencyKey];
}

- (NSString *)imageURL
{
    return [self.jobData valueForKey:kJobImageURLKey];
}

- (void)setImageURL:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobImageURLKey];
}

- (NSString *)imageKey
{
    return self.requestID;
}

- (UIImage *)image
{        
    NSString *imageKey = self.imageKey;
        
    if ([imageKey length] > 0) {
        return [XMImageCache loadImageForKey:imageKey];
    }
    return nil;
}

- (NSData *)imageData
{
    
    NSString *imageKey = self.imageKey;
    
    if ([imageKey length] > 0) {
        return [XMImageCache loadImageDataForKey:imageKey];
    }
    return nil;
}

- (UIImage *)thumbnail
{
        
    NSString *thumbnailKey = self.thumbnailKey;
        
    if ([thumbnailKey length] > 0) {
        return [XMImageCache loadImageForKey:thumbnailKey];
    }
    
    return nil;
}

- (NSString *)thumbnailKey
{
    if (!self.requestID) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@%@", self.requestID, @"_thumb"];
}

- (void)populateObjectFromServerJSON:(NSDictionary *)serverJSON {
    self.jobData = [NSMutableDictionary dictionaryWithDictionary:serverJSON];
}

- (NSString *)durationSinceLastAction
{
    NSString *dateString = @"";
    
    NSDate *timeToUse = self.transcriptionTime ? self.transcriptionTime : self.submissionTime;
    
    if (timeToUse) {
        // TODO - proper date formatting...we want values like "26 min ago"
        dateString = [timeToUse description];
    }
    
    return dateString;
}

- (NSDictionary *)submissionMetaData
{
    NSDictionary *metaData = @{kJobRequestIDKey : self.requestID, kJobAuthIDKey : [[XMXimlyHTTPClient sharedClient] getAuthID], kJobDeviceIDKey : [[XMXimlyHTTPClient sharedClient] getDeviceID], kJobSubmissionTimeKey : [NSString stringWithFormat:@"%lld", (long long)[self submissionTimeInMs]], kJobUrgencyKey : @"0"} ;
    
    return metaData;
}

@end
