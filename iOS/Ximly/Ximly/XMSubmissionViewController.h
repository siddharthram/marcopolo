//
//  XMSubmissionViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMSubmissionViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIActionSheet *photoSourceSelectionSheet;
@property (strong, nonatomic) UIImage *pickedImage;

- (void)showSelectionSheet;


@end
