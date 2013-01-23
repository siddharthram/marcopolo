//
//  XMIntroViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMSubmissionViewController.h"

@interface XMIntroViewController : UIViewController <XMSubmissionDelegate>

- (IBAction)doStart:(id)sender;

@end
