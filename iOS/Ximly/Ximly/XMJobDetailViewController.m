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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *titleText = [self.jobData valueForKey:@"title"];
    self.title = titleText ? titleText : @"Untitled";
    
    NSString *imageKey = [self.jobData valueForKey:@"imageKey"];
    
    UIImage *anImage = nil;
    
    if ([imageKey length] > 0) {
        anImage = [XMImageCache loadImageForKey:imageKey];
    }
    
    if (anImage) {
        self.imageView.image = anImage;
    } else {
        self.imageView.image = [UIImage imageNamed:@"Default.png"];
    }
    
    NSString *transcribedText = [self.jobData valueForKey:@"transcription"];
    self.transcribedTextView.text = transcribedText ? transcribedText : @"Not Yet Available";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
