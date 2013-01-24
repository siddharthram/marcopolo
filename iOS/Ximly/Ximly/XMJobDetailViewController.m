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

- (UIImage *)getImage
{
    UIImage *theImage = nil;

    NSString *imageKey = [self.jobData valueForKey:@"imageKey"];
    
    if ([imageKey length] > 0) {
        theImage = [XMImageCache loadImageForKey:imageKey];
    }
    
    if (!theImage) {
        theImage = [UIImage imageNamed:@"Default.png"];
    }
    
    return theImage;
}

- (NSString *)getMessageForSharing
{
    NSString *messageText = @"";
    
    NSString *titleText = [self.jobData valueForKey:@"title"];
    NSString *transcribedText = [self.jobData valueForKey:@"transcription"];

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

    NSString *titleText = [self.jobData valueForKey:@"title"];
    self.titleLabel.text = titleText ? titleText : @"Untitled";
    
    self.imageView.image = [self getImage];
    
    NSString *transcribedText = [self.jobData valueForKey:@"transcription"];
    self.transcribedTextView.text = transcribedText ? transcribedText : @"Transcription Not Yet Available";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)share:(id)sender
{
    NSArray *postItems = @[[self getImage], [self getMessageForSharing]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
