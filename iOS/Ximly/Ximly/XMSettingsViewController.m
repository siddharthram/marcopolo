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
#import "XMPurchaseManager.h"
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
    
    self.purchaseLevel1Button.enabled = NO;
    self.purchaseLevel2Button.enabled = NO;
    self.purchaseLevel3Button.enabled = NO;
    [[XMPurchaseManager sharedInstance] setDelegate:self];
    [[XMPurchaseManager sharedInstance] fetchProducts];

    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *deviceID = [userDefaults stringForKey:kDeviceIDPrefKey];
    
    self.navigationItem.title = @"Transcriptions";
    
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
    
    BOOL inAppPurchaseEnabled = [XMPurchaseManager isPurchasingEnabled];
    
    if (inAppPurchaseEnabled) {
        self.inAppPurchaseSwitch.on = YES;
    } else {
        self.inAppPurchaseSwitch.on = NO;
    }
    
    self.currentDeviceIDLabel.text = [[XMXimlyHTTPClient sharedClient] getDeviceID];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.numTranscriptionsLabel.text = [NSString stringWithFormat:@"%d",[XMXimlyHTTPClient getImagesLeft]];
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

- (IBAction)emailDeviceID:(id)sender
{

        if ([MFMailComposeViewController canSendMail]) {
            
            MFMailComposeViewController *emailEditor = [MFMailComposeViewController new];
            
            [emailEditor setSubject:@"Ximly device id"];
            [emailEditor setMessageBody:[[XMXimlyHTTPClient sharedClient] getDeviceID] isHTML:NO];
            emailEditor.mailComposeDelegate = self;
            [self presentViewController:emailEditor animated:YES completion:nil];
        } 

}

- (IBAction)purchaseLevel1Product
{
    [[XMPurchaseManager sharedInstance] setDelegate:self];
    [[XMPurchaseManager sharedInstance] purchaseLevel1Product];
}

- (IBAction)purchaseLevel2Product
{
    [[XMPurchaseManager sharedInstance] setDelegate:self];
    [[XMPurchaseManager sharedInstance] purchaseLevel2Product];
}

- (IBAction)purchaseLevel3Product
{
    [[XMPurchaseManager sharedInstance] setDelegate:self];
    [[XMPurchaseManager sharedInstance] purchaseLevel3Product];
}


- (void)didFetchProducts:(NSDictionary *)products
{
    self.purchaseLevel1Button.enabled = YES;
    self.purchaseLevel2Button.enabled = YES;
    self.purchaseLevel3Button.enabled = YES;
    [self.purchaseLevel1Button setTitle:[NSString stringWithFormat:@"Buy 5-Pack @ $%@", [[[[[XMPurchaseManager sharedInstance] listOfProducts] objectForKey:kLevel1ProductCode] price] stringValue]] forState:UIControlStateNormal];
    [self.purchaseLevel2Button setTitle:[NSString stringWithFormat:@"Buy 20-Pack @ $%@", [[[[[XMPurchaseManager sharedInstance] listOfProducts] objectForKey:kLevel2ProductCode] price] stringValue]] forState:UIControlStateNormal];
    [self.purchaseLevel3Button setTitle:[NSString stringWithFormat:@"Buy 100-Pack @ $%@", [[[[[XMPurchaseManager sharedInstance] listOfProducts] objectForKey:kLevel3ProductCode] price] stringValue]] forState:UIControlStateNormal];
    
}

- (void)failedToStartPurchase
{
    //TODO
}

- (void)didProcessTransactionSuccessfully:(int)numAvailable
{
    self.numTranscriptionsLabel.text = [NSString stringWithFormat:@"%d",[XMXimlyHTTPClient getImagesLeft]];
}

- (void)didProcessTransactionUnsuccessfully
{
    self.numTranscriptionsLabel.text = [NSString stringWithFormat:@"%d",[XMXimlyHTTPClient getImagesLeft]];
}

- (void)didProcessTransactionWithAppleError:(NSError *)error
{
    self.numTranscriptionsLabel.text = [NSString stringWithFormat:@"%d",[XMXimlyHTTPClient getImagesLeft]];
}

- (void)didProcessTransactionWithXimlyError:(int)errorCode
{
    self.numTranscriptionsLabel.text = [NSString stringWithFormat:@"%d",[XMXimlyHTTPClient getImagesLeft]];
}

#pragma mark - Mail composer delegate method

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
