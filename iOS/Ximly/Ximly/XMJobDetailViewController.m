//
//  XMJobDetailViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMJobDetailViewController.h"

#import "XMImageCache.h"
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
    
    CALayer *boxLayer = self.imageView.layer;
    boxLayer.cornerRadius = 14.0;
    boxLayer.masksToBounds = YES;
    boxLayer.borderWidth = 4;
    boxLayer.borderColor = [[UIColor blackColor] CGColor];

    NSString *titleText = self.job.title;
    self.title = titleText ? titleText : @"Untitled";
    
    /*
    NSURL *url = [NSURL fileURLWithPath:[XMImageCache cacheFilePathForKey:self.job.imageKey]];
    [self.imageView loadRequest:[NSURLRequest requestWithURL:url]];
    */
    CGFloat width = self.imageView.frame.size.width;
    NSString *html = [NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"width=%f; maximum-scale=4.0; user-scalable=1;\"/></head><body><img src=\"%@\" width=\"%f\"/></body></html>", width, self.job.imageKey, width - 16.0];
    [self.imageView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[XMImageCache cacheFolderPath]]];
    
    NSString *transcribedText = self.job.userTranscription;
    
    if ([transcribedText length] > 0) {
        self.transcribedTextView.text = transcribedText;
    } else {
        self.titleLabel.text = @"Transcription not yet available";
        self.transcribedTextView.text = @"";
    }
    
    [self hideSendingToEvernoteUI];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.imageView reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)share:(id)sender
{
    NSArray *postItems = @[self.job.image, [self getMessageForSharing]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)rate:(id)sender
{
    self.rateJobViewController = [[XMRateJobViewController alloc] initWithNibName:@"XMRateJobViewController" bundle:nil];
    self.rateJobViewController.job = self.job;
    
    CGRect rateJobFrame = self.rateJobViewController.view.frame;
    rateJobFrame.size.height = self.view.bounds.size.height;
    rateJobFrame.size.width = self.view.bounds.size.width;
    self.rateJobViewController.view.frame = rateJobFrame;
    
    [self.view addSubview:self.rateJobViewController.view];
    
    // TODO - Write ratings to disk (create a singleton history list that we can read and write from disk anywhere in the app)
}

- (void)showSendingToEvernoteUI {
    [toolbar setItems:[NSArray arrayWithObjects:actionButton, rateButton, flexibleSpace, sendingToEvernoteView, nil]];
}

- (void)hideSendingToEvernoteUI {
    [toolbar setItems:[NSArray arrayWithObjects:actionButton, rateButton, flexibleSpace, sendToEvernoteButton, nil]];
}

- (IBAction)saveToEvernote:(id)sender {
    [self showSendingToEvernoteUI];
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            [self hideSendingToEvernoteUI];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Sorry, we were unable to connect to your Evernote account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        } else {
            NSString *transcribedText = self.job.userTranscription;
            if ([transcribedText length] <= 0) {
                transcribedText = @"Transcription not yet available";
            }
            
            NSString *titleText = self.job.title ? self.job.title : @"Untitled";
            
            NSData *imageData = UIImagePNGRepresentation(self.job.image);
            NSData *dataHash = [imageData md5];
            EDAMData *edamData = [[EDAMData alloc] initWithBodyHash:dataHash size:imageData.length body:imageData];
            EDAMResource* resource = [[EDAMResource alloc] initWithGuid:nil noteGuid:nil data:edamData mime:@"image/png" width:0 height:0 duration:0 active:0 recognition:0 attributes:nil updateSequenceNum:0 alternateData:nil];
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
                                     "</en-note>",titleText, transcribedText, [ENMLUtility mediaTagWithDataHash:dataHash mime:@"image/png"]];
            NSMutableArray* resources = [NSMutableArray arrayWithArray:@[resource]];
            EDAMNote *newNote = [[EDAMNote alloc] initWithGuid:nil title:titleText content:noteContent contentHash:nil contentLength:noteContent.length created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:nil tagGuids:nil resources:resources attributes:nil tagNames:nil];
            [[EvernoteNoteStore noteStore] createNote:newNote success:^(EDAMNote *note) {
                [self hideSendingToEvernoteUI];
                NSLog(@"Note created successfully.");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your note was successfully sent to Evernote." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            } failure:^(NSError *error) {
                [self hideSendingToEvernoteUI];
                NSLog(@"Error creating note : %@",error);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, we were unable to send your note to Evernote. Error: %@", [error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }];
        } 
    }];
}

@end
