//
//  XMRateJobViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/26/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMRateJobViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "XMJobList.h"
#import "XMUtilities.h"
#import "XMXimlyHTTPClient.h"
#import "Flurry.h"

@interface XMRateJobViewController ()

@end

@implementation XMRateJobViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CALayer *boxLayer = self.ratingBox.layer;
    boxLayer.cornerRadius = 14.0;
    boxLayer.masksToBounds = YES;
    boxLayer.borderWidth = 6;
    boxLayer.borderColor = [[UIColor blackColor] CGColor];
 
    self.rating = self.job.rating;
    [self drawRatingBox];
    
    self.commentTextView.returnKeyType = UIReturnKeyDone;
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification
											   object:nil];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)drawRatingBox
{
    CGRect ratingBoxFrame = self.ratingBox.frame;
    
    if ([self.rating length] > 0) {
        ratingBoxFrame.size.height = 258.0;
        NSString *comment = self.job.ratingComment;
        self.commentTextView.text = comment ? comment : @"";
        if ([self.rating isEqualToString:kJobRatingGood]) {
            self.goodButton.selected = YES;
            self.badButton.selected = NO;
        } else if ([self.rating isEqualToString:kJobRatingBad]) {
            self.goodButton.selected = NO;
            self.badButton.selected = YES;
        } else {
            // Error state
            self.goodButton.selected = NO;
            self.badButton.selected = NO;
        }
        self.commentBackdrop.hidden = NO;
        self.submitButton.hidden = NO;
    } else {
        self.commentBackdrop.hidden = YES;
        self.submitButton.hidden = YES;
        ratingBoxFrame.size.height = 115.0;
    }
    
    self.ratingBox.frame = ratingBoxFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rateAsGood:(id)sender
{
    [Flurry logEvent:@"Rate good"];
    if ([self.rating length] == 0) {
        self.rating = kJobRatingGood;
        [UIView animateWithDuration:.3 animations:^(void){[self drawRatingBox]; [self.commentTextView becomeFirstResponder];}];
    } else {
        self.rating = kJobRatingGood;
        self.goodButton.selected = YES;
        self.badButton.selected = NO;
    }
}

- (IBAction)rateAsBad:(id)sender
{
    [Flurry logEvent:@"Rate bad"];
    if ([self.rating length] == 0) {
        self.rating = kJobRatingBad;
        [UIView animateWithDuration:.3 animations:^(void){[self drawRatingBox]; [self.commentTextView becomeFirstResponder];}];
    } else {
        self.rating = kJobRatingBad;
        self.goodButton.selected = NO;
        self.badButton.selected = YES;
    }
}

- (IBAction)goodButtonTouched:(id)sender
{
    self.badButton.selected = NO;
}

- (IBAction)badButtonTouched:(id)sender
{
    self.goodButton.selected = NO;
    
}

- (IBAction)submit:(id)sender
{
    self.job.rating = self.rating;
    self.job.ratingComment = self.commentTextView.text;
    [[XMXimlyHTTPClient sharedClient] rateJob:self.job];
    [[XMJobList sharedInstance] writeToDisk];  // TODO - get data back from the cloud or mark record as local if call to cloud fails
    [self.view removeFromSuperview];
}

- (IBAction)close:(id)sender
{
    [self.view removeFromSuperview];    
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGFloat screenHeight = [XMUtilities heightOfScreen];
    CGFloat shiftDelta = 61.0;

    if (screenHeight > 960.0) {
        shiftDelta = 51.0;
    }
    
    [UIView animateWithDuration:.2 animations:^(void){
        CGRect aFrame = self.ratingBox.frame;
        aFrame.origin.y -= shiftDelta;
        self.ratingBox.frame = aFrame;
        
        aFrame = self.closeButton.frame;
        aFrame.origin.y -= shiftDelta;
        self.closeButton.frame = aFrame;
    }];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    CGFloat screenHeight = [XMUtilities heightOfScreen];
    CGFloat shiftDelta = 61.0;
    
    if (screenHeight > 960.0) {
        shiftDelta = 51.0;
    }
    
    [UIView animateWithDuration:.2 animations:^(void){
        CGRect aFrame = self.ratingBox.frame;
        aFrame.origin.y += shiftDelta;
        self.ratingBox.frame = aFrame;
        
        aFrame = self.closeButton.frame;
        aFrame.origin.y += shiftDelta;
        self.closeButton.frame = aFrame;
    }];
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

@end
