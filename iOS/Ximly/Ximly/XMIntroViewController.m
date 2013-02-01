//
//  XMIntroViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMIntroViewController.h"

#import "XMAppDelegate.h"
#import "XMHistoryViewController.h"
#import "XMUtilities.h"

@interface XMIntroViewController ()

@end

@implementation XMIntroViewController

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
    
    CGFloat screenHeight = [XMUtilities heightOfScreen];
    
    if (screenHeight == 480.0) {
        self.backgroundImageView.image = [UIImage imageNamed:@"Default.png"];
    } else if (screenHeight) {
        self.backgroundImageView.image = [UIImage imageNamed:@"Default@2x.png"];
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"Default-568h@2x.png"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setBool:YES forKey:@"hasSeenInstructions"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doStart:(id)sender
{
    XMAppDelegate *appDelegate = (XMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showSubmissionViewWithDelegate:self];
}

#pragma mark - XMSubmission delegate methods

- (void)submissionCancelled
{
    XMAppDelegate *appDelegate = (XMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showHistoryView];
}

- (void)jobSubmitted:(XMJob *)job
{
    XMAppDelegate *appDelegate = (XMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showHistoryView];
}

@end
