//
//  XMSettingsViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 2/6/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMSettingsViewController.h"

#import "XMImageCache.h"
#import "XMJobList.h"
#import "XMXimlyHTTPClient.h"
#import "Flurry.h"

@interface XMSettingsViewController ()

@end

@implementation XMSettingsViewController

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *deviceID = [userDefaults stringForKey:kDeviceIDPrefKey];
    
    if ([deviceID length] > 0) {
        self.deviceIDSwitch.on = YES;
        self.deviceIDField.enabled = YES;
        self.deviceIDField.text = deviceID;
    } else {
        self.deviceIDSwitch.on = NO;
        self.deviceIDField.enabled = NO;
        self.deviceIDField.text = @"";
    }
    
    BOOL alwaysShowIntro = [userDefaults boolForKey:kShowIntroPrefKey];
    
    if (alwaysShowIntro) {
        self.showIntroSwitch.on = YES;
    } else {
        self.showIntroSwitch.on = NO;
    }
    
    self.currentDeviceIDLabel.text = [[XMXimlyHTTPClient sharedClient] getDeviceID];

}

- (void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:self.deviceIDField.text forKey:kDeviceIDPrefKey];
    [userDefaults synchronize];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showIntroSwitchChanged
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.showIntroSwitch.on forKey:kShowIntroPrefKey];
    [userDefaults synchronize];
}

- (IBAction)deviceIDSwitchChanged
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (self.deviceIDSwitch.on == YES) {
        self.deviceIDField.text = @"";
        self.deviceIDField.enabled = YES;
        [self deleteCache:self];
    } else {
        self.deviceIDField.enabled = NO;
        self.deviceIDField.text = @"";
        [userDefaults removeObjectForKey:kDeviceIDPrefKey];
        [userDefaults synchronize];
    }
}

- (IBAction)deleteCache:(id)sender
{
    [Flurry logEvent:@"Delete cache"];
    [[XMJobList sharedInstance] removeAllJobs];
    [[XMJobList sharedInstance] writeToDisk];
    [XMImageCache deleteCache];
    [[NSNotificationCenter defaultCenter] postNotificationName:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
}

@end
