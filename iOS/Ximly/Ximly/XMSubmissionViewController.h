//
//  XMSubmissionViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define XM_NOTIFICATION_JOB_SUBMITTED      @"XM_NOTIFICATION_JOB_SUBMITTED"

@protocol XMSubmissionDelegate <NSObject>

- (void)submissionCancelled;
- (void)submissionCompletedForJob:(NSDictionary *)jobData;

@end


@interface XMSubmissionViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) NSObject<XMSubmissionDelegate> *delegate;

@property (strong, nonatomic) UIActionSheet *photoSourceSelectionSheet;
@property (strong, nonatomic) UIImage *pickedImage;

- (void)startSubmissionWithDelegate:(NSObject<XMSubmissionDelegate> *)submissionDelegate;

@end
