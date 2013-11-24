//
//  XMHistoryTableViewCell.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMHistoryTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbnailView;
@property (nonatomic, weak) IBOutlet UIView *thumbnailShadowView;
@property (nonatomic, weak) IBOutlet UIView *backdrop;
@property (nonatomic, weak) IBOutlet UIView *backdropShadow;
@property (nonatomic, weak) IBOutlet UITextView *transcriptionView;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *waitIndicator;

@end
