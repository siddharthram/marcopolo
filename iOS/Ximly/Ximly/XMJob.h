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
#define kJobTranscriptionKey            @"transcriptionData"
#define kJobUserTranscriptionKey        @"userTranscriptionData"
#define kJobStatusKey                   @"status"
#define kJobSubmissionTimeKey           @"clientSubmitTimeStamp"
#define kJobServerSubmissionTimeKey     @"serverSubmissionTimeStamp"
#define kJobTranscriptionTimeKey        @"transcriptionTimeStamp"
#define kJobTranscriptionIDKey          @"transcriptionId"
#define kJobRatingKey                   @"rating"
#define kJobRatingCommentKey            @"ratingComment"
#define kJobImageURLKey                 @"imageUrl"
#define kJobImageKey                    @"imageKey"
#define kJobThumbnailKey                @"thumbnailKey"
#define kJobUrgencyKey                  @"urgency"
#define kJobReqeustedResponseFormat     @"requestedResponseFormat"
#define KJobAttachmentUrl               @"attachmentUrl"



typedef enum {
    JobStatusOpen             = 0,
    JobStatusLocked           = 1,
    JobStatusTranscribed      = 2
} JobStatus;

#define kJobStatusNoneString          @""
#define kJobStatusOpenString    @"SUBMITTED"
#define kJobStatusLockedString  @"TRANSCRIBING"
#define kJobStatusTranscribedString   @"TRANSCRIBED"



@interface XMJob : NSObject {

}

@property (nonatomic, strong) NSMutableDictionary *jobData;

@property (nonatomic, readwrite) NSString *requestID;
@property (nonatomic, readwrite) NSString *serverRequestID;
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *transcription;
@property (nonatomic, readwrite) NSString *userTranscription;
@property (nonatomic, readwrite) NSString *status;
@property (nonatomic, readwrite) NSDate *submissionTime;
@property (nonatomic, readwrite) NSDate *serverSubmissionTime;
@property (nonatomic, readwrite) NSDate *transcriptionTime;
@property (nonatomic, readwrite) NSString *transcriptionID;
@property (nonatomic, readwrite) NSString *rating;
@property (nonatomic, readwrite) NSString *ratingComment;
@property (nonatomic, readwrite) NSString *imageURL;
@property (nonatomic, readonly) NSString *imageKey;
@property (nonatomic, readonly) NSString *thumbnailKey;
@property (nonatomic, assign) int urgency;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) UIImage *thumbnail;
@property (nonatomic, readonly) NSData *imageData;
@property (nonatomic, readonly) NSString *durationSinceLastAction;
@property (nonatomic, readonly) BOOL isPending;
@property (nonatomic, readonly) BOOL isDone;
@property (nonatomic, readwrite) NSString *requestedResponseFormat;
@property (nonatomic, readwrite) NSString *attachmentUrl;
@property (nonatomic, readonly) NSString *attachmentKey;


- (NSDictionary *)submissionMetaData;

- (void)populateObjectFromServerJSON:(NSDictionary *)serverJSON;

@end
