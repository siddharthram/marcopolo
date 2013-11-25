//
//  XMJob.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/26/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMJob.h"

#import "XMImageCache.h"
#import "XMUtilities.h"
#import "XMXimlyHTTPClient.h"
#import "AFImageRequestOperation.h"

#define kNumberOfFields 14

static UIImage *s_submittedStatusImage = nil;
static UIImage *s_transcribingStatusImage = nil;
static UIImage *s_transcribedStatusImage = nil;
static UIImage *s_errorStatusImage = nil;


@implementation XMJob 

@dynamic requestID;
@dynamic serverRequestID;
@dynamic title;
@dynamic transcription;
@dynamic userTranscription;
@dynamic status;
@dynamic submissionTime;
@dynamic serverSubmissionTime;
@dynamic transcriptionTime;
@dynamic transcriptionID;
@dynamic rating;
@dynamic ratingComment;
@dynamic imageURL;
@dynamic imageKey;
@dynamic image;
@dynamic thumbnailKey;
@dynamic thumbnail;
@dynamic durationSinceLastAction;
@dynamic isPending;
@dynamic requestedResponseFormat;
@dynamic attachmentUrl;
@dynamic attachmentKey;
@dynamic statusImage;


+ (UIImage *)submittedStatusImage
{
    if (!s_submittedStatusImage) {
        s_submittedStatusImage = [UIImage imageNamed:@"icon_status_waiting_for_worker"];
    }
    return s_submittedStatusImage;
}

+ (UIImage *)transcribingStatusImage
{
    if (!s_transcribingStatusImage) {
        s_transcribingStatusImage = [UIImage imageNamed:@"icon_status_beingworkedon"];
    }
    return s_transcribedStatusImage;
}

+ (UIImage *)transcribedStatusImage
{
    if (!s_transcribedStatusImage) {
        s_transcribedStatusImage = [UIImage imageNamed:@"icon_status_transcribed"];
    }
    return s_transcribedStatusImage;
}

+ (UIImage *)errorStatusImage
{
    if (!s_errorStatusImage) {
        s_errorStatusImage = [UIImage imageNamed:@"icon_status_work_alert"];
    }
    return s_errorStatusImage;
}


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

- (NSString *)userTranscription
{
    return [self.jobData valueForKey:kJobUserTranscriptionKey];
}

- (void)setUserTranscription:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobUserTranscriptionKey];
}

- (BOOL)isPending
{
    NSNumber *status = [self.jobData valueForKey:kJobStatusKey];
    int statusInt = [status intValue];
    return ((statusInt == JobStatusOpen) || (statusInt == JobStatusLocked));
}

- (BOOL)isDone
{
    NSNumber *status = [self.jobData valueForKey:kJobStatusKey];
    return ([status intValue] == JobStatusTranscribed);
}


- (NSString *)status
{
    NSString *statusStr = kJobStatusNoneString;
    NSNumber *status = [self.jobData valueForKey:kJobStatusKey];
    
    if (status) {
        switch ([status intValue]) {
            case JobStatusOpen:
                statusStr = kJobStatusOpenString;
                break;
                
            case JobStatusLocked:
                statusStr = kJobStatusLockedString;
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

- (UIImage *)statusImage
{
    UIImage *statusImage = nil;
    NSNumber *status = [self.jobData valueForKey:kJobStatusKey];
    
    if (status) {
        switch ([status intValue]) {
            case JobStatusOpen:
                statusImage = [XMJob submittedStatusImage];
                break;
                
            case JobStatusLocked:
                statusImage = [XMJob transcribingStatusImage];
                break;
                
            case JobStatusTranscribed:
                statusImage = [XMJob transcribedStatusImage];
                break;
                
            default:
                statusImage = [XMJob errorStatusImage];
                break;
        }
    }
    
    return statusImage;
}

- (void)setStatus:(NSString *)value
{
    NSNumber *newStatus = nil;
    
    if ([value isEqualToString:kJobStatusTranscribedString]) {
        newStatus = [NSNumber numberWithInt:JobStatusTranscribed];
    } else if ([value isEqualToString:kJobStatusOpenString]) {
        newStatus = [NSNumber numberWithInt:JobStatusOpen];
    } else if ([value isEqualToString:kJobStatusLockedString]) {
        newStatus = [NSNumber numberWithInt:JobStatusLocked];
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

- (NSString *)transcriptionID
{
    NSNumber *idNum = [self.jobData valueForKey:kJobTranscriptionIDKey];
    return [idNum stringValue];}

- (void)setTranscriptionID:(NSString *)value
{
    [self.jobData setValue:[NSNumber numberWithLongLong:[value longLongValue]] forKey:kJobTranscriptionIDKey];
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
        return [XMImageCache loadAttachmentDataForKey:imageKey];
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

- (NSString *)requestedResponseFormat
{
    return [self.jobData valueForKey:kJobReqeustedResponseFormat];
}

- (void)setRequestedResponseFormat:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobReqeustedResponseFormat];
}

- (NSString *)attachmentUrl
{
    return [self.jobData valueForKey:kJobAttachmentUrl];
}

- (void)setAttachmentUrl:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobAttachmentUrl];
}

- (NSString *)attachmentKey
{
    NSString *fileExtension = [self.attachmentUrl pathExtension];
    
    if ([fileExtension length] == 0) {
        fileExtension = @"pptx";
    }
    
    return [NSString stringWithFormat:@"%@.%@", self.requestID, fileExtension];
}

- (NSData *)attachment
{
    NSString *attachmentKey = self.attachmentKey;
    
    if ([attachmentKey length] > 0) {
        return [XMAttachmentCache loadAttachmentDataForKey:attachmentKey];
    }
    return nil;
}

- (void)populateObjectFromServerJSON:(NSDictionary *)serverJSON {
    self.jobData = [NSMutableDictionary dictionaryWithDictionary:serverJSON];
}

- (NSString *)durationSinceLastAction
{
    NSString *dateString = @"";
    
    NSDate *dateToUse = self.transcriptionTime ? self.transcriptionTime : self.submissionTime;
    
    if (dateToUse) {
        dateString = [XMUtilities timeAgoFromUnixTime:[dateToUse timeIntervalSince1970]];
    }
    
    return dateString;
}

- (NSDictionary *)submissionMetaData
{
    NSDictionary *metaData = @{kJobRequestIDKey : self.requestID, kJobAuthIDKey : [[XMXimlyHTTPClient sharedClient] getAuthID], kJobDeviceIDKey : [[XMXimlyHTTPClient sharedClient] getDeviceID], kJobSubmissionTimeKey : [NSString stringWithFormat:@"%lld", (long long)[self submissionTimeInMs]], kJobUrgencyKey : @"0", kJobReqeustedResponseFormat : self.requestedResponseFormat} ;
    
    return metaData;
}

@end
