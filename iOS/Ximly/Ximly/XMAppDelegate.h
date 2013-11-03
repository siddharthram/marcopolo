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
#import "EvernoteSDK.h"

#define kAPNSDeviceTokenKey         @"apnsDeviceId"

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@interface XMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *historyNavController;
@property (strong, nonatomic) XMHistoryViewController *historyViewController;
@property (strong, nonatomic) XMSubmissionViewController *submissionViewController;
@property (strong, nonatomic) NSData *apnsDeviceToken;
@property (assign, nonatomic) BOOL isLaunching;

- (void)showIntroView;
- (void)showSubmissionViewWithDelegate:(NSObject<XMSubmissionDelegate> *)submissionDelegate;
- (void)showHistoryView;

@end
