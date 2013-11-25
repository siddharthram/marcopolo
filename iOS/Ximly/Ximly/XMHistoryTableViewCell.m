//
//  XMHistoryTableViewCell.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMHistoryTableViewCell.h"
#import "XMColor.h"

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
    /*
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:.96 green:.96 blue:.96 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0] CGColor], nil];
    [self.layer insertSublayer:gradient atIndex:0];
    */
  
    CALayer *boxLayer = self.thumbnailView.layer;
    boxLayer.masksToBounds = YES;
    boxLayer.cornerRadius = 5.0;
    boxLayer.borderWidth = 1;
    boxLayer.borderColor = [UIColor whiteColor].CGColor;

  //  boxLayer.borderColor = [XMColor lightGrayColor].CGColor;

//    boxLayer.shouldRasterize = YES;

/*
    
//    CALayer *boxShadowLayer = self.thumbnailShadowView.layer;
//    boxShadowLayer.cornerRadius = 3.0;
    boxLayer.shadowColor = [[UIColor darkGrayColor] CGColor];
    boxLayer.shadowOpacity = 0.7;
//    boxShadowLayer.shadowRadius = 3.0;
    boxLayer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.thumbnailView.bounds cornerRadius:3.0];
    boxLayer.shadowPath = path.CGPath;
    
*/
    
    CALayer *backdropLayer = self.backdrop.layer;
    backdropLayer.cornerRadius = 5.0;
    backdropLayer.masksToBounds = YES;
    backdropLayer.borderWidth = 1;
    backdropLayer.borderColor = [XMColor lightGrayColor].CGColor;
//    backdropLayer.shouldRasterize = YES;

    /*
    CALayer *backdropShadowLayer = self.backdropShadow.layer;
    backdropShadowLayer.cornerRadius = 5.0;
    backdropShadowLayer.shadowColor = [[UIColor darkGrayColor] CGColor];
    backdropShadowLayer.shadowOpacity = 0.4;
    backdropShadowLayer.shadowRadius = 2.0;
    backdropShadowLayer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    path = [UIBezierPath bezierPathWithRoundedRect:self.backdropShadow.bounds cornerRadius:5.0];
    backdropShadowLayer.shadowPath = path.CGPath;
     */

}

@end
