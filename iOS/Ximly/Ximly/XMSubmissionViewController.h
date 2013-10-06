//
//  XMSubmissionViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPurchaseManager.h"

#import "XMJob.h"

@protocol XMSubmissionDelegate <NSObject>

- (void)submissionCancelled;
- (void)jobSubmitted:(XMJob *)job;

@end


@interface XMSubmissionViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, XMPurchaseManagerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) NSObject<XMSubmissionDelegate> *delegate;

@property (strong, nonatomic) UIActionSheet *photoSourceSelectionSheet;
@property (strong, nonatomic) UIImage *pickedImage;
@property (assign) BOOL isFetchingProducts;
@property (strong, nonatomic) UIActionSheet *requestFormatActionSheet;
@property (assign) BOOL requestPPTSlide;


- (void)startSubmissionWithDelegate:(NSObject<XMSubmissionDelegate> *)submissionDelegate;
- (void)askUserToPurchaseTranscriptions;

@end
