//
//  XMJobDetailViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMJobDetailViewController.h"

#import <MessageUI/MFMailComposeViewController.h>
#import "XMAttachmentCache.h"
#import "XMImageCache.h"
#import "XMXimlyHTTPClient.h"
#import "Flurry.h"
#import <QuartzCore/QuartzCore.h>


@interface XMJobDetailViewController ()

@end

@implementation XMJobDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)getMessageForSharing
{
    NSString *messageText = @"";
    
    NSString *titleText = self.job.title;
    NSString *transcribedText = self.job.userTranscription;

    if ([titleText length] > 0) {
        if ([transcribedText length] > 0) {
            messageText = [NSString stringWithFormat:@"%@: %@", titleText, transcribedText];
        } else {
            messageText = titleText;
        }
    } else {
        if ([transcribedText length] > 0) {
            messageText = transcribedText;
        } else {
            // No message
        }
    }
    return messageText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editJob)];
    
    UIImage *myImage = [UIImage imageNamed:@"detail_icon_rate"];
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton setImage:myImage forState:UIControlStateNormal];
    myButton.showsTouchWhenHighlighted = YES;
    myButton.frame = CGRectMake(0.0, 3.0, 24, 24);
    [myButton addTarget:self action:@selector(rate:) forControlEvents:UIControlEventTouchUpInside];
    self.rateButton = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    
    
    myImage = [UIImage imageNamed:@"detail_icon_evernote"];
    myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton setImage:myImage forState:UIControlStateNormal];
    myButton.showsTouchWhenHighlighted = YES;
    myButton.frame = CGRectMake(0.0, 3.0, 24, 24);
    [myButton addTarget:self action:@selector(saveToEvernote:) forControlEvents:UIControlEventTouchUpInside];
    self.sendToEvernoteButton = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    
    [self hideSendingToEvernoteUI];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self redisplay:YES];
}

- (void)redisplay:(BOOL)reloadImage
{
    
    if (reloadImage) {
      
        /*
         NSURL *url = [NSURL fileURLWithPath:[XMImageCache cacheFilePathForKey:self.job.imageKey]];
         [self.imageView loadRequest:[NSURLRequest requestWithURL:url]];
         */
        
        if ([self.job.attachmentUrl length] > 0) {
            [self.attachmentView setContentMode:UIViewContentModeScaleAspectFit];
            [self.attachmentView setScalesPageToFit:YES];
            
            if ([XMAttachmentCache cacheFileExistsForKey:self.job.attachmentKey]) {
                NSString *filePath = [XMAttachmentCache cacheFilePathForKey:self.job.attachmentKey];
                NSURL *url = [NSURL fileURLWithPath:filePath];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [self.attachmentView loadRequest:request];
            } else {
                __weak XMJobDetailViewController *weakSelf = self;
                [[XMXimlyHTTPClient sharedClient] fetchAttachmentWithURL:[NSURL URLWithString:self.job.attachmentUrl]
                                                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                     [XMAttachmentCache saveAttachmentData:(NSData *)responseObject withKey:weakSelf.job.attachmentKey];
                                                                     NSString *filePath = [XMAttachmentCache cacheFilePathForKey:weakSelf.job.attachmentKey];
                                                                     NSURL *url = [NSURL fileURLWithPath:filePath];
                                                                     NSURLRequest *request = [NSURLRequest requestWithURL:url];
                                                                     [weakSelf.attachmentView loadRequest:request];
                                                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                 }];
            }
        } else {
            [self.attachmentView removeFromSuperview];
        }
        
        CGFloat width = self.imageView.frame.size.width;
        
        NSString *html = [NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"width=%f; maximum-scale=4.0; user-scalable=1;\"/></head><body leftmargin=\"0px\" topmargin=\"0px\" marginwidth=\"0px\" marginheight=\"0px\"><img src=\"%@\" width=\"%f\"/></body></html>", width, self.job.imageKey, width];
        [self.imageView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[XMImageCache cacheFolderPath]]];
    }

    
    NSString *titleText = self.job.userTranscription;
    self.title = [titleText length] > 0 ? titleText : @"";
    
    if (self.job.isDone) {
        self.titleLabel.hidden = YES;
        NSString *transcribedText = self.job.userTranscription;
        self.transcribedTextView.text = [transcribedText length] > 0 ? transcribedText : @"";
        self.rateButton.enabled = YES;
    } else {
        self.titleLabel.hidden = NO;
        self.transcribedTextView.text = @"";
        self.rateButton.enabled = NO;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self redisplay:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)share:(id)sender
{
    [Flurry logEvent:@"Share tapped"];
    
    NSArray *postItems = nil;
    NSArray *activityTypesToExclude = nil;
    
    if ([self.job.attachmentUrl length] > 0) {
        postItems = @[[NSURL fileURLWithPath:[XMAttachmentCache cacheFilePathForKey:self.job.attachmentKey]]];
        activityTypesToExclude = [MFMailComposeViewController canSendMail] ? @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll] : @[UIActivityTypeMail, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];

    } else {
        postItems = @[self.job.image, [self getMessageForSharing]];
        activityTypesToExclude = [MFMailComposeViewController canSendMail] ? nil : @[UIActivityTypeMail];
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    
                     activityVC.excludedActivityTypes = activityTypesToExclude;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)rate:(id)sender
{
    [Flurry logEvent:@"Rate tapped"];
    self.rateJobViewController = [[XMRateJobViewController alloc] initWithNibName:@"XMRateJobViewController" bundle:nil];
    self.rateJobViewController.job = self.job;
    
    CGRect rateJobFrame = self.rateJobViewController.view.frame;
    rateJobFrame.size.height = self.view.bounds.size.height;
    rateJobFrame.size.width = self.view.bounds.size.width;
    self.rateJobViewController.view.frame = rateJobFrame;
    
    [self.view addSubview:self.rateJobViewController.view];
}

- (void)showSendingToEvernoteUI {
    [toolbar setItems:[NSArray arrayWithObjects:actionButton, fixedSpace, self.rateButton, flexibleSpace, sendingToEvernoteView, nil]];
}

- (void)hideSendingToEvernoteUI {
    [toolbar setItems:[NSArray arrayWithObjects:actionButton, fixedSpace, self.rateButton, flexibleSpace, self.sendToEvernoteButton, nil]];
}

- (IBAction)saveToEvernote:(id)sender {
    [Flurry logEvent:@"Evernote tapped"];
    [self showSendingToEvernoteUI];
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            [Flurry logEvent:@"Evernote connect failed"];
            [self hideSendingToEvernoteUI];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Sorry, we were unable to connect to your Evernote account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        } else {
            [Flurry logEvent:@"Evernote connect success"];
            NSString *transcribedText = self.job.userTranscription;
            if (self.job.attachmentUrl.length > 0) {
                transcribedText = @"Transcription attached.";
            }
            else {
                if ([transcribedText length] <= 0) {
                    transcribedText = @"Transcription not yet available.";
                }
            }
            
            NSString *titleText = self.job.title ? self.job.title : @"Untitled";
            
            NSData *dataHash = [self.job.imageData md5];
            EDAMData *edamData = [[EDAMData alloc] initWithBodyHash:dataHash size:self.job.imageData.length body:self.job.imageData];
            EDAMResource* resource = [[EDAMResource alloc] initWithGuid:nil noteGuid:nil data:edamData mime:@"image/jpeg" width:0 height:0 duration:0 active:0 recognition:0 attributes:nil updateSequenceNum:0 alternateData:nil];
            
            EDAMResource *attachmentResource = nil;
            NSString *attachmentContent = @"";
            if (self.job.attachmentUrl.length > 0) {
                NSString *attachmentMime = @"application/vnd.openxmlformats-officedocument.presentationml.presentation";
                if ([[self.job.attachmentUrl pathExtension] isEqualToString:@"ppt"]) {
                    attachmentMime = @"application/vnd.ms-powerpoint";
                }
                attachmentContent = [NSString stringWithFormat:@"%@", [ENMLUtility mediaTagWithDataHash:[self.job.attachment md5] mime:attachmentMime]];
                EDAMData *attachmentEdamData = [[EDAMData alloc] initWithBodyHash:[self.job.attachment md5] size:self.job.attachment.length body:self.job.attachment];
                EDAMResourceAttributes *attachmentEDAMResourceAttributes = [[EDAMResourceAttributes alloc] init];
                attachmentEDAMResourceAttributes.fileName = @"Transcription";
                attachmentResource = [[EDAMResource alloc] initWithGuid:nil noteGuid:nil data:attachmentEdamData mime:attachmentMime width:0 height:0 duration:0 active:0 recognition:0 attributes:attachmentEDAMResourceAttributes updateSequenceNum:0 alternateData:nil];
            }
            NSString *noteContent = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                     "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
                                     "<en-note>"
                                     "<span style=\"font-weight:bold;\">%@</span>"
                                     "<br />"
                                     "<br />"
                                     "<span>%@</span>"
                                     "<br />"
                                     "<br />"
                                     "%@"
                                     "<br />"
                                     "<br />"
                                     "%@"
                                     "</en-note>",titleText, transcribedText, [ENMLUtility mediaTagWithDataHash:dataHash mime:@"image/jpeg"], attachmentContent];
            
            NSMutableArray* resources = [NSMutableArray arrayWithArray:@[resource]];
            if (attachmentResource != nil) {
                [resources addObject:attachmentResource];
            }
            
            EDAMNote *newNote = [[EDAMNote alloc] initWithGuid:nil title:titleText content:noteContent contentHash:nil contentLength:noteContent.length created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:nil tagGuids:nil resources:resources attributes:nil tagNames:nil];
            [[EvernoteNoteStore noteStore] createNote:newNote success:^(EDAMNote *note) {
                [Flurry logEvent:@"Evernote send note success"];
                [self hideSendingToEvernoteUI];
                NSLog(@"Note created successfully.");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your transcription was successfully sent to Evernote." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            } failure:^(NSError *error) {
                [Flurry logEvent:@"Evernote send note failed"];
                [self hideSendingToEvernoteUI];
                NSLog(@"Error creating note : %@",error);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, we were unable to send your transcription to Evernote. Error: %@", error] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }];
        } 
    }];
}

- (void)editJob
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    
    [UIView animateWithDuration:.3 animations:^(void){
        self.transcribedTextView.editable = YES;
    }];
}

- (void)save
{
    
}

@end
