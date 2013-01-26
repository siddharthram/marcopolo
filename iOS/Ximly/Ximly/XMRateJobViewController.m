//
//  XMRateJobViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/26/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMRateJobViewController.h"

#import <QuartzCore/QuartzCore.h>

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CALayer *boxLayer = self.ratingBox.layer;
    boxLayer.cornerRadius = 14.0;
    boxLayer.masksToBounds = YES;
    boxLayer.borderWidth = 6;
    boxLayer.borderColor = [[UIColor blackColor] CGColor];
 
    self.rating = [self.jobData valueForKey:@"rating"];
    [self drawRatingBox];
}

- (void)drawRatingBox
{
    CGRect ratingBoxFrame = self.ratingBox.frame;
    
    if ([self.rating length] > 0) {
        ratingBoxFrame.size.height = 252.0;
        NSString *comment = [self.jobData valueForKey:@"ratingComment"];
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
    if ([self.rating length] == 0) {
        self.rating = kJobRatingGood;
        [UIView animateWithDuration:.3 animations:^(void){[self drawRatingBox];}];
    } else {
        self.rating = kJobRatingGood;
        self.goodButton.selected = YES;
        self.badButton.selected = NO;
    }
}

- (IBAction)rateAsBad:(id)sender
{
    if ([self.rating length] == 0) {
        self.rating = kJobRatingBad;
        [UIView animateWithDuration:.3 animations:^(void){[self drawRatingBox];}];
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
    [self.jobData setValue:self.rating forKey:@"rating"];
    [self.jobData setValue:self.commentTextView.text forKey:@"ratingComment"];
    [self.view removeFromSuperview];
}

- (IBAction)close:(id)sender
{
    [self.view removeFromSuperview];    
}

@end
