//
//  XMAppDelegate.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMHistoryViewController.h"
#import "XMIntroViewController.h"
#import "XMSubmissionViewController.h"

#define kAPNSDeviceTokenKey         @"apnsDeviceId"

@interface XMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *historyNavController;
@property (strong, nonatomic) XMHistoryViewController *historyViewController;
@property (strong, nonatomic) XMSubmissionViewController *submissionViewController;
@property (strong, nonatomic) NSData *apnsDeviceToken;

- (void)showIntroView;
- (void)showSubmissionViewWithDelegate:(NSObject<XMSubmissionDelegate> *)submissionDelegate;
- (void)showHistoryView;

@end
