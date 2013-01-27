//
//  XMJobDetailViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMJobDetailViewController.h"

#import "XMImageCache.h"

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
    NSString *transcribedText = self.job.transcription;

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

    NSString *titleText = self.job.title;
    self.titleLabel.text = titleText ? titleText : @"Untitled";
    
    self.imageView.image = self.job.image;
    
    NSString *transcribedText = self.job.transcription;
    self.transcribedTextView.text = transcribedText ? transcribedText : @"Transcription not yet available";
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
    [self.view addSubview:self.rateJobViewController.view];
    
    // TODO - Write ratings to disk (create a singleton history list that we can read and write from disk anywhere in the app)
}

@end
