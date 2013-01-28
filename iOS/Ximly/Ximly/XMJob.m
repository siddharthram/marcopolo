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

@implementation XMJob 

@dynamic requestID;
@dynamic title;
@dynamic status;
@dynamic submissionTime;
@dynamic finishTime;
@dynamic rating;
@dynamic ratingComment;
@dynamic imageKey;
@dynamic image;
@dynamic durationSinceLastAction;


- (NSString *)requestID
{
    return [self.jobData valueForKey:kJobRequestIDKey];
}

- (void)setRequestID:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobRequestIDKey];
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
    return [self.jobData valueForKey:kJobStatusKey];
}

- (void)setStatus:(NSString *)value
{
    [self.jobData setValue:value forKey:kJobStatusKey];
}

- (NSDate *)submissionTime
{
    return [self.jobData valueForKey:kJobSubmissionTimeKey];
}

- (void)setSubmissionTime:(NSDate *)value
{
    [self.jobData setValue:value forKey:kJobSubmissionTimeKey];
}

- (NSDate *)finishTime
{
    return [self.jobData valueForKey:kJobFinishTimeKey];
}

- (void)setFinishTime:(NSDate *)value
{
    [self.jobData setValue:value forKey:kJobFinishTimeKey];
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
    NSDictionary *metaData = @{kJobRequestIDKey : self.requestID, @"auth_id" : [[XMXimlyHTTPClient sharedClient] getAuthID], @"device_id" : [[XMXimlyHTTPClient sharedClient] getDeviceID], kJobSubmissionTimeKey : [NSString stringWithFormat:@"%lld", (long long)[[NSDate date] timeIntervalSince1970]*1000], kJobUrgencyKey : @"0"} ;
    
    return metaData;
}

@end
