//
//  XMImageCache.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/23/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMImageCache.h"

#import "UIImage+XMAdditions.h"
#import "XMJob.h"
#import "XMUtilities.h"


@implementation XMImageCache


+ (NSData *)saveImage:(UIImage *)image forJob:(XMJob *)job
{
    
    UIImage *resizedImage = [UIImage shrink:image toMaxSide:800];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.6);
    [self saveAttachmentData:imageData withKey:job.imageKey];
    
    resizedImage = [UIImage shrink:image toMaxSide:100];
    NSData *thumbnailData = UIImageJPEGRepresentation(resizedImage, 0.6);
    [self saveAttachmentData:thumbnailData withKey:job.thumbnailKey];
    
    return imageData;
}

+ (UIImage *)loadImageForKey:(NSString *)key
{
    return [UIImage imageWithContentsOfFile:[self cacheFilePathForKey:key]];
}


@end
