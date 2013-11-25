//
//  XMJobDetailViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMJob.h"
#import "XMRateJobViewController.h"
#import "EvernoteSDK.h"
#import "ENMLUtility.h"
#import "NSData+EvernoteSDK.h"

@interface XMJobDetailViewController : UIViewController {
    IBOutlet UIBarButtonItem *actionButton;
    IBOutlet UIBarButtonItem *fixedSpace;
    IBOutlet UIBarButtonItem *flexibleSpace;
    IBOutlet UIBarButtonItem *sendingToEvernoteView;
    IBOutlet UIToolbar *toolbar;
}

@property (nonatomic, strong) XMJob *job;
@property (nonatomic, weak) IBOutlet UIView *backdrop;
@property (nonatomic, weak) IBOutlet UIView *backdropShadow;
@property (nonatomic, weak) IBOutlet UIWebView *imageView;
@property (nonatomic, weak) IBOutlet UIView *imageShadowView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextView *transcribedTextView;
@property (nonatomic, weak) IBOutlet UIImageView *transcribedTextShadowView;
@property (nonatomic, strong) IBOutlet UIWebView *attachmentView;
@property (nonatomic, strong) XMRateJobViewController *rateJobViewController;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *rateButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sendToEvernoteButton;


- (IBAction)share:(id)sender;
- (IBAction)rate:(id)sender;
- (IBAction)saveToEvernote:(id)sender;

@end
