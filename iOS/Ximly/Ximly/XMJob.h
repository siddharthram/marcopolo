//
//  XMJob.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/26/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kJobRequestIDKey        @"client_request_id"
#define kJobTitleKey            @"title"
#define kJobTranscriptionKey    @"transcription"
#define kJobStatusKey           @"status"
#define kJobSubmissionTimeKey   @"client_submission_timestamp"
#define kJobFinishTimeKey       @"finishTime"
#define kJobRatingKey           @"rating"
#define kJobRatingCommentKey    @"ratingComment"
#define kJobImageKey            @"imageKey"
#define kJobUrgencyKey          @"urgency"


@interface XMJob : NSObject {
    UIImage *_image;
}

@property (nonatomic, strong) NSMutableDictionary *jobData;

@property (nonatomic, readwrite) NSString *requestID;
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *transcription;
@property (nonatomic, readwrite) NSString *status;
@property (nonatomic, readwrite) NSDate *submissionTime;
@property (nonatomic, readwrite) NSDate *finishTime;
@property (nonatomic, readwrite) NSString *rating;
@property (nonatomic, readwrite) NSString *ratingComment;
@property (nonatomic, readwrite) NSString *imageKey;
@property (nonatomic, assign) int urgency;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSString *durationSinceLastAction;

- (void)setImage:(UIImage *)anImage withKey:(NSString *)theImageKey;

- (NSDictionary *)submissionMetaData;

@end
