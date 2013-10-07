//
//  XMSettingsViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 2/6/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "XMPurchaseManager.h"

#define kShowIntroPrefKey   @"ShowIntroPrefKey"
#define kDeviceIDPrefKey    @"DeviceIDPrefKey"

@interface XMSettingsViewController : UIViewController <MFMailComposeViewControllerDelegate, XMPurchaseManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel        *numTranscriptionsLabel;
@property (nonatomic, weak) IBOutlet UISwitch       *showIntroSwitch;
@property (nonatomic, weak) IBOutlet UISwitch       *inAppPurchaseSwitch;
@property (nonatomic, weak) IBOutlet UISwitch       *deviceIDSwitch;
@property (nonatomic, weak) IBOutlet UITextField    *deviceIDField;
@property (nonatomic, weak) IBOutlet UILabel        *currentDeviceIDLabel;

@property (nonatomic, weak) IBOutlet UIButton        *purchaseLevel1Button;
@property (nonatomic, weak) IBOutlet UIButton        *purchaseLevel2Button;
@property (nonatomic, weak) IBOutlet UIButton        *purchaseLevel3Button;

- (IBAction)showIntroSwitchChanged;
- (IBAction)deviceIDSwitchChanged;
- (IBAction)deleteCache:(id)sender;
- (IBAction)emailDeviceID:(id)sender;

- (IBAction)purchaseLevel1Product;
- (IBAction)purchaseLevel2Product;
- (IBAction)purchaseLevel3Product;

@end
