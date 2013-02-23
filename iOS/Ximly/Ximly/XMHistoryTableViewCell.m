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
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:.96 green:.96 blue:.96 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0] CGColor], nil];
    [self.layer insertSublayer:gradient atIndex:0];
    
    CALayer *boxLayer = self.thumbnailView.layer;
    boxLayer.cornerRadius = 6.0;
    boxLayer.masksToBounds = YES;
    boxLayer.borderWidth = 3;
    boxLayer.borderColor = [[UIColor blackColor] CGColor];
}

@end
