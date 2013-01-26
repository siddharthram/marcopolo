//
//  XMRateJobViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/26/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJobRatingGood @"Good"
#define kJobRatingBad @"Bad"

@interface XMRateJobViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *ratingBox;
@property (nonatomic, weak) IBOutlet UIButton *goodButton;
@property (nonatomic, weak) IBOutlet UIButton *badButton;
@property (nonatomic, weak) IBOutlet UITextView *commentTextView;
@property (nonatomic, weak) IBOutlet UIView *commentBackdrop;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) NSMutableDictionary *jobData;
@property (nonatomic, strong) NSString *rating;

- (IBAction)rateAsGood:(id)sender;
- (IBAction)rateAsBad:(id)sender;
- (IBAction)goodButtonTouched:(id)sender;
- (IBAction)badButtonTouched:(id)sender;
- (IBAction)submit:(id)sender;
- (IBAction)close:(id)sender;

@end
