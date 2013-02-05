//
//  XMHistoryTableViewCell.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMHistoryTableViewCell.h"

#import <QuartzCore/QuartzCore.h>

@implementation XMHistoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CALayer *boxLayer = self.thumbnailView.layer;
    boxLayer.cornerRadius = 6.0;
    boxLayer.masksToBounds = YES;
    boxLayer.borderWidth = 3;
    boxLayer.borderColor = [[UIColor blackColor] CGColor];
}

@end
