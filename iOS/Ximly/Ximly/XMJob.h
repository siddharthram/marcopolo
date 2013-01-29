//
//  XMJob.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/26/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kJobAuthIDKey                   @"authId"
#define kJobDeviceIDKey                 @"deviceId"

#define kJobRequestIDKey                @"clientUniqueRequestId"
#define kJobServerReqeustIDKey          @"serverUniqueRequestId"
#define kJobTitleKey                    @"title"
#define kJobTranscriptionKey            @"transcription"
#define kJobStatusKey                   @"status"
#define kJobSubmissionTimeKey           @"clientSubmitTimeStamp"
#define kJobServerSubmissionTimeKey     @"serverSubmissionTimeStamp"
#define kJobFinishTimeKey               @"finishTime"
#define kJobRatingKey                   @"rating"
#define kJobRatingCommentKey            @"ratingComment"
#define kJobImageURLKey                 @"imageUrl"
#define kJobImageKey                    @"imageKey"
#define kJobUrgencyKey                  @"urgency"


typedef enum {
    JobStatusProcessing       = 0,
    JobStatusTranscribed      = 2,
} JobStatus;

#define kJobStatusNoneString          @""
#define kJobStatusProcessingString    @"PROCESSING"
#define kJobStatusTranscribedString   @"DONE!"



@interface XMJob : NSObject {
    UIImage *_image;
}

@property (nonatomic, strong) NSMutableDictionary *jobData;

@property (nonatomic, readwrite) NSString *requestID;
@property (nonatomic, readwrite) NSString *serverRequestID;
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *transcription;
@property (nonatomic, readwrite) NSString *status;
@property (nonatomic, readwrite) NSDate *submissionTime;
@property (nonatomic, readwrite) NSDate *serverSubmissionTime;
@property (nonatomic, readwrite) NSDate *finishTime;
@property (nonatomic, readwrite) NSString *rating;
@property (nonatomic, readwrite) NSString *ratingComment;
@property (nonatomic, readwrite) NSString *imageURL;
@property (nonatomic, readwrite) NSString *imageKey;
@property (nonatomic, assign) int urgency;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSString *durationSinceLastAction;

- (void)setImage:(UIImage *)anImage withKey:(NSString *)theImageKey;

- (NSDictionary *)submissionMetaData;

- (void)populateObjectFromServerJSON:(NSDictionary *)serverJSON;

@end
