//
//  XMAppDelegate.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMAppDelegate.h"

@implementation XMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL hasSeenInstructions = [userDefaults boolForKey:@"hasSeenInstructions"];
    
    if (!hasSeenInstructions) {
        [self showIntroView];
    } else {
        [self showHistoryView];
    }
    
    
    return YES;
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

- (void)showSubmissionView
{
    if (!self.submissionViewController) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.submissionViewController = [[XMSubmissionViewController alloc] initWithNibName:@"XMSubmissionViewController_iPhone" bundle:nil];
        } else {
            self.submissionViewController = [[XMSubmissionViewController alloc] initWithNibName:@"XMSubmissionViewController_iPad" bundle:nil];
        }
    }
    self.window.rootViewController = self.submissionViewController;
    [self.window makeKeyAndVisible];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
