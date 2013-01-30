//
//  UIImage+XMAdditions.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/29/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "UIImage+XMAdditions.h"

@implementation UIImage (XMAdditions)

// Scale image to a size (No cropping)
+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    
    // Graphics operation
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0f);
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// Scale down image so that the maximum length of either side is less than or equal to maxDimension.  If the image
// is already smaller, the image is returned unchanged.
+ (UIImage *)scaleDownImage:(UIImage *)image toMaxDimension:(CGFloat)maxDimension
{
    CGSize origSize = [image size];
    UIImage *resizedImage = image;
    if ((origSize.width > maxDimension) || (origSize.height > maxDimension)) {
        CGSize newSize;
        if (origSize.width > origSize.height) {
            newSize.height = maxDimension * origSize.height / origSize.width;
            newSize.width = maxDimension;
        } else {
            newSize.width = maxDimension * origSize.width / origSize.height;
            newSize.height = maxDimension;
        }
        resizedImage = [UIImage scaleImage:image toSize:newSize];
    }
    return resizedImage;
}

@end
