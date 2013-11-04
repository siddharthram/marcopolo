//
//  UINavigationController+Orientation.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 11/3/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "UINavigationController+Orientation.h"

@implementation UINavigationController (Orientation)

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
