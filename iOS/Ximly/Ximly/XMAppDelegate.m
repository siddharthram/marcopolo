//
//  XMAppDelegate.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMAppDelegate.h"
#import "XMColor.h"
#import "XMXimlyHTTPClient.h"
#import "XMSettingsViewController.h"
#import "Flurry.h"

@implementation XMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [[UINavigationBar appearance] setBarTintColor:[XMColor navBarColor]];
    [[UISearchBar appearance] setBackgroundImage:[UIImage new]];
    [[UISearchBar appearance] setTintColor:[XMColor navBarColor]];
    [[UISearchBar appearance] setBackgroundColor:[XMColor navBarColor]];
    [[UISearchBar appearance] setBarTintColor:[XMColor navBarColor]];

    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary
                             dictionaryWithObjectsAndKeys:[UIColor
                                                           darkGrayColor],UITextAttributeTextColor,[NSValue
                                                                                                 valueWithUIOffset:UIOffsetMake(0,
                                                                                                                                1)],UITextAttributeTextShadowOffset,nil]
     forState:UIControlStateNormal];

//    [[UINavigationBar appearance] setTintColor:[XMColor greenColor]];


 //   [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if (![XMXimlyHTTPClient isRegistered]) {
        self.isLaunching = YES;
        [[XMXimlyHTTPClient sharedClient] registerDeviceWithAPNSToken:nil updateAPNS:NO delegate:nil];
    }
        
    [self showHistoryView];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSDictionary *remoteNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif) {
        [self alertUserToUpdatedJobs:remoteNotif];
    }
    
    // Initial development is done on the sandbox service
    // Change this to BootstrapServerBaseURLStringUS to use the production Evernote service
    // Change this to BootstrapServerBaseURLStringCN to use the Yinxiang Biji production service
    // BootstrapServerBaseURLStringSandbox does not support the  Yinxiang Biji service
    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringUS;
    
    NSString *CONSUMER_KEY = @"sidgidwani";
    NSString *CONSUMER_SECRET = @"2983be5f158d8a7e";
    
    // set up Evernote session singleton
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST
                              consumerKey:CONSUMER_KEY
                           consumerSecret:CONSUMER_SECRET];
    
    [Flurry startSession:@"ZVKPTTGDRS7GRHHQ9CCR"];
    [Flurry setSessionReportsOnPauseEnabled:YES];
    


    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
#ifdef _DEBUG_
	NSLog(@"My token is: %@", deviceToken);
#endif
    self.apnsDeviceToken = deviceToken;
    [[XMXimlyHTTPClient sharedClient] registerDeviceWithAPNSToken:self.apnsDeviceToken updateAPNS:YES delegate:nil];
//    [Flurry logEvent:@"Accept Push Notifications"];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
 //   [Flurry logEvent:@"Decline Push Notifications"];
	NSLog(@"Failed to get token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
#ifdef _DEBUG_
	NSLog(@"Got Notification%@",userInfo);
#endif
	if ( application.applicationState == UIApplicationStateActive ){
 //       [Flurry logEvent:@"Receive push: App open"];
		// App was in forefront
		[[XMXimlyHTTPClient sharedClient] updateTasks];
        if (self.historyViewController && self.historyNavController && (self.window.rootViewController == self.historyNavController) && (self.historyNavController.visibleViewController == self.historyNavController)) {
            application.applicationIconBadgeNumber = 0;
        }
        [self alertUserToUpdatedJobs:userInfo];
    }
    else
    {
   //     [Flurry logEvent:@"Open with Push"];
        // App was just brought from background to forefront
        // We call '[[XMXimlyHTTPClient sharedClient] updateTasks]' in applicationDidBecomeActive: so there's nothing to do here
    }
}

- (void)alertUserToUpdatedJobs:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]  delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)showIntroView
{
    XMIntroViewController *introViewController = [[XMIntroViewController alloc] initWithNibName:@"XMIntroViewController" bundle:nil];
    self.window.rootViewController = introViewController;
    [self.window makeKeyAndVisible];
}

- (void)showHistoryView
{
    if (!self.historyViewController) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.historyViewController = [[XMHistoryViewController alloc] initWithNibName:@"XMHistoryViewController_iPhone" bundle:nil];
        } else {
            // TODO
        }
    }
    
    if (!self.historyNavController) {
        self.historyNavController= [[UINavigationController alloc] initWithRootViewController:self.historyViewController];
  //      self.historyNavController.navigationBar.barStyle = UIBarStyleDefault;
    }

    self.window.rootViewController = self.historyNavController;
    [self.window makeKeyAndVisible];
}

- (void)showSubmissionViewWithDelegate:(NSObject<XMSubmissionDelegate> *)submissionDelegate
{
    if (!self.submissionViewController) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.submissionViewController = [[XMSubmissionViewController alloc] initWithNibName:@"XMSubmissionViewController_iPhone" bundle:nil];
        } else {
            self.submissionViewController = [[XMSubmissionViewController alloc] initWithNibName:@"XMSubmissionViewController_iPad" bundle:nil];
        }
    }
    [self.window addSubview:self.submissionViewController.view];
//    [self.submissionViewController askUserToPurchaseTranscriptions];
    [self.submissionViewController startSubmissionWithDelegate:submissionDelegate];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL canHandle = NO;
    if ([[NSString stringWithFormat:@"en-%@", [[EvernoteSession sharedSession] consumerKey]] isEqualToString:[url scheme]] == YES) {
        canHandle = [[EvernoteSession sharedSession] canHandleOpenURL:url];
    }
    return canHandle;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[XMPurchaseManager sharedInstance] stopObservingTransactions];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [Flurry logEvent:@"App closed"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (!self.isLaunching && ![XMXimlyHTTPClient isRegistered]) {
        [[XMXimlyHTTPClient sharedClient] registerDeviceWithAPNSToken:nil updateAPNS:NO delegate:nil];
    } else {
        self.isLaunching = NO;
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    [[XMXimlyHTTPClient sharedClient] updateTasks];
    
    [[EvernoteSession sharedSession] handleDidBecomeActive];
    
 //   [Flurry logEvent:@"App launched"];
    
    [[XMPurchaseManager sharedInstance] startObservingTransactions];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
