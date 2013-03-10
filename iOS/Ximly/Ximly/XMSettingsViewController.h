//
//  XMSettingsViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 2/6/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kShowIntroPrefKey   @"ShowIntroPrefKey"
#define kDeviceIDPrefKey    @"DeviceIDPrefKey"

@interface XMSettingsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UISwitch       *showIntroSwitch;
@property (nonatomic, weak) IBOutlet UISwitch       *deviceIDSwitch;
@property (nonatomic, weak) IBOutlet UITextField    *deviceIDField;
@property (nonatomic, weak) IBOutlet UILabel        *currentDeviceIDLabel;

- (IBAction)showIntroSwitchChanged;
- (IBAction)deviceIDSwitchChanged;
- (IBAction)deleteCache:(id)sender;

@end
