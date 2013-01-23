//
//  XMJobDetailViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMJobDetailViewController.h"

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
    
    UIImage *theImage = [self.jobData valueForKey:@"image"];
    
    if (theImage) {
        self.imageView.image = theImage;
    } else {
        self.imageView.image = [UIImage imageNamed:@"intro.png"];
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
