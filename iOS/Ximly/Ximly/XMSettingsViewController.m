//
//  XMSettingsViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 2/6/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMSettingsViewController.h"

#import "XMColor.h"
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
    
    [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
    
    self.purchaseLevel1Button.layer.cornerRadius = 3;
    self.purchaseLevel2Button.layer.cornerRadius = 3;
    self.purchaseLevel3Button.layer.cornerRadius = 3;
    self.purchaseLevel1Button.layer.borderWidth = 2;
    self.purchaseLevel2Button.layer.borderWidth = 2;
    self.purchaseLevel3Button.layer.borderWidth = 2;
    self.purchaseLevel1Button.layer.borderColor = [XMColor greenColor].CGColor;
    self.purchaseLevel2Button.layer.borderColor = [XMColor greenColor].CGColor;
    self.purchaseLevel3Button.layer.borderColor = [XMColor greenColor].CGColor;

    self.purchaseLevel1Button.enabled = NO;
    self.purchaseLevel2Button.enabled = NO;
    self.purchaseLevel3Button.enabled = NO;
    self.plus1Label.hidden = YES;
    self.plus2Label.hidden = YES;
    self.plus3Label.hidden = YES;
    self.number1Label.hidden = YES;
    self.number2Label.hidden = YES;
    self.number3Label.hidden = YES;
    self.credits1Label.hidden = YES;
    self.credits2Label.hidden = YES;
    self.credits3Label.hidden = YES;
    self.price1Label.hidden = YES;
    self.price2Label.hidden = YES;
    self.price3Label.hidden = YES;
    self.off2Label.hidden = YES;
    self.off3Label.hidden = YES;

    [[XMPurchaseManager sharedInstance] setDelegate:self];
    [[XMPurchaseManager sharedInstance] fetchProducts];

    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *deviceID = [userDefaults stringForKey:kDeviceIDPrefKey];
    
    self.navigationItem.title = @"Credits";
    
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
    [self.purchaseLevel1Button setTitle:@"" forState:UIControlStateNormal];
    [self.purchaseLevel2Button setTitle:@"" forState:UIControlStateNormal];
    [self.purchaseLevel3Button setTitle:@"" forState:UIControlStateNormal];
    
    self.plus1Label.hidden = NO;
    self.plus2Label.hidden = NO;
    self.plus3Label.hidden = NO;
    self.number1Label.hidden = NO;
    self.number2Label.hidden = NO;
    self.number3Label.hidden = NO;
    self.credits1Label.hidden = NO;
    self.credits2Label.hidden = NO;
    self.credits3Label.hidden = NO;
    self.price1Label.hidden = NO;
    self.price2Label.hidden = NO;
    self.price3Label.hidden = NO;
    NSString *price1 = [NSString stringWithFormat:@"$%@",[[[[[XMPurchaseManager sharedInstance] listOfProducts] objectForKey:kLevel1ProductCode] price] stringValue]];
    NSString *price2 = [NSString stringWithFormat:@"$%@",[[[[[XMPurchaseManager sharedInstance] listOfProducts] objectForKey:kLevel2ProductCode] price] stringValue]];
    NSString *price3 = [NSString stringWithFormat:@"$%@",[[[[[XMPurchaseManager sharedInstance] listOfProducts] objectForKey:kLevel3ProductCode] price] stringValue]];
    self.price1Label.text = price1;
    self.price2Label.text = price2;
    self.price3Label.text = price3;
    if ([price1 isEqualToString:@"$4.99"] && [price2 isEqualToString:@"$17.99"] && [price3 isEqualToString:@"$79.99"]) {
        self.off2Label.hidden = NO;
        self.off3Label.hidden = NO;
    }
    
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
