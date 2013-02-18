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
@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UILabel *label2;
@property (nonatomic, weak) IBOutlet UILabel *label3;
@property (nonatomic, weak) IBOutlet UIImageView *ratingImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *waitIndicator;

@end
