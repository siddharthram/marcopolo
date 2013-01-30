//
//  UIImage+XMAdditions.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/29/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (XMAdditions)

+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)newSize;
+ (UIImage *)scaleDownImage:(UIImage *)image toMaxDimension:(CGFloat)maxDimension;

@end
