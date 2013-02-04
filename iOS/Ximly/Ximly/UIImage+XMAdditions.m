//
//  UIImage+XMAdditions.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/29/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "UIImage+XMAdditions.h"

@implementation UIImage (XMAdditions)

// Based on code from http://www.icodesnip.com/search/objective-c%20scale/
+ (UIImage*)scale:(UIImage*)image toSize:(CGSize)newSize {
    
    if ([[UIScreen mainScreen] scale] == 2.0) {
        // Retina
        UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0f);
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)shrink:(UIImage *)image toMaxSide:(CGFloat)maxSide
{
    CGSize origSize = [image size];
    UIImage *resizedImage = image;
    if ((origSize.width > maxSide) || (origSize.height > maxSide)) {
        CGSize newSize;
        if (origSize.width > origSize.height) {
            newSize.height = maxSide * origSize.height / origSize.width;
            newSize.width = maxSide;
        } else {
            newSize.width = maxSide * origSize.width / origSize.height;
            newSize.height = maxSide;
        }
        resizedImage = [UIImage scale:image toSize:newSize];
    }
    return resizedImage;
}

- (UIImage *)crop:(CGRect)rect {
    if (self.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

@end
