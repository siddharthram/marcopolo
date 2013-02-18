//
//  XMAppDelegate.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMAppDelegate.h"
#import "XMXimlyHTTPClient.h"
#import "XMSettingsViewController.h"
#import "Flurry.h"

@implementation XMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL hasSeenInstructions = [userDefaults boolForKey:@"hasSeenInstructions"];
    BOOL alwaysShowIntro = [userDefaults boolForKey:kShowIntroPrefKey];
    
    if (!hasSeenInstructions || alwaysShowIntro) {
        [self showIntroView];
    } else {
        [self showHistoryView];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    UILocalNotification *remoteNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif) {
        [self alertUserToUpdatedJobs:remoteNotif.userInfo];
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
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    self.apnsDeviceToken = deviceToken;
    [[XMXimlyHTTPClient sharedClient] registerAPNSDeviceToken:self.apnsDeviceToken];
    [Flurry logEvent:@"Accept Push Notifications"];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [Flurry logEvent:@"Decline Push Notifications"];
	NSLog(@"Failed to get token, error: %@", error);

}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"Got Notification%@",userInfo);
	if ( application.applicationState == UIApplicationStateActive ){
        [Flurry logEvent:@"Receive push: App open"];
		// App was in forefront
		[[XMXimlyHTTPClient sharedClient] updateTasks];
        if (self.historyViewController && self.historyNavController && (self.window.rootViewController == self.historyNavController) && (self.historyNavController.visibleViewController == self.historyNavController)) {
            application.applicationIconBadgeNumber = 0;
        }
        [self alertUserToUpdatedJobs:userInfo];
    }
    else
    {
        [Flurry logEvent:@"Open with Push"];
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
        self.historyNavController.navigationBar.barStyle = UIBarStyleBlack;
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
    [[XMXimlyHTTPClient sharedClient] updateTasks];
    
    [[EvernoteSession sharedSession] handleDidBecomeActive];
    
    [Flurry logEvent:@"App launched"];
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
