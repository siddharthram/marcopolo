//
//  XMSettingsViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 2/6/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


#define kShowIntroPrefKey   @"ShowIntroPrefKey"
#define kDeviceIDPrefKey    @"DeviceIDPrefKey"

@interface XMSettingsViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel        *numTranscriptionsLabel;
@property (nonatomic, weak) IBOutlet UISwitch       *showIntroSwitch;
@property (nonatomic, weak) IBOutlet UISwitch       *inAppPurchaseSwitch;
@property (nonatomic, weak) IBOutlet UISwitch       *deviceIDSwitch;
@property (nonatomic, weak) IBOutlet UITextField    *deviceIDField;
@property (nonatomic, weak) IBOutlet UILabel        *currentDeviceIDLabel;

- (IBAction)showIntroSwitchChanged;
- (IBAction)inAppPurchaseSwitchChanged;
- (IBAction)deviceIDSwitchChanged;
- (IBAction)deleteCache:(id)sender;
- (IBAction)resetTranscriptionCounts:(id)sender;
- (IBAction)emailDeviceID:(id)sender;

@end
