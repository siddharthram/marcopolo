//
//  XMJobDetailViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMRateJobViewController.h"

@interface XMJobDetailViewController : UIViewController

@property (nonatomic, strong) NSMutableDictionary *jobData;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextView *transcribedTextView;
@property (nonatomic, strong) XMRateJobViewController *rateJobViewController;

- (IBAction)share:(id)sender;
- (IBAction)rate:(id)sender;

@end
