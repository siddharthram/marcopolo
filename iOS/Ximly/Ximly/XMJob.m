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

#define kNumberOfFields 11

@implementation XMJob 

@dynamic requestID;
@dynamic serverRequestID;
@dynamic title;
@dynamic transcription;
@dynamic status;
@dynamic submissionTime;
@dynamic serverSubmissionTime;
@dynamic finishTime;
@dynamic rating;
@dynamic ratingComment;
@dynamic imageURL;
@dynamic imageKey;
@dynamic image;
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

- (NSDate *)finishTime
{
    double timeInMs = [self submissionTimeInMs];
    if (timeInMs != 0) {
        return [NSDate dateWithTimeIntervalSince1970:timeInMs/1000];
    }
    return nil;
}

- (void)setFinishTime:(NSDate *)value
{
    long long timeInMs = (long long)[value timeIntervalSince1970] * 1000;
    [self.jobData setValue:[NSNumber numberWithLongLong:timeInMs] forKey:kJobFinishTimeKey];
}

- (double)finishTimeInMs
{
    NSNumber *timeNum = [self.jobData valueForKey:kJobFinishTimeKey];
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

- (void)setImageKey:(NSString *)value
{
    self.requestID = value;
}

- (UIImage *)image
{
    if (!_image) {
        
        NSString *imageKey = self.imageKey;
        
        if ([imageKey length] > 0) {
            _image = [XMImageCache loadImageForKey:imageKey];
        }
        
        if (!_image) {
            _image = [UIImage imageNamed:@"Default.png"];
        }
    }
    
    return _image;
}

- (void)populateObjectFromServerJSON:(NSDictionary *)serverJSON {
    self.jobData = [NSMutableDictionary dictionaryWithDictionary:serverJSON];
}

- (void)setImage:(UIImage *)anImage withKey:(NSString *)theImageKey
{
    _image = anImage;
    self.imageKey = theImageKey;
}

- (NSString *)durationSinceLastAction
{
    NSString *dateString = @"";
    
    NSDate *timeToUse = self.finishTime ? self.finishTime : self.submissionTime;
    
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
