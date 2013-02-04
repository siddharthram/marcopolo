//
//  UIImage+XMAdditions.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/29/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (XMAdditions)

+ (UIImage*)scale:(UIImage*)image toSize:(CGSize)newSize;
+ (UIImage *)shrink:(UIImage *)image toMaxSide:(CGFloat)maxSide;

@end
