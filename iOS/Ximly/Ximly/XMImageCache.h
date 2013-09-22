//
//  XMImageCache.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/23/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMAttachmentCache.h"

@class XMJob;

@interface XMImageCache : XMAttachmentCache

+ (NSData *)saveImage:(UIImage *)image forJob:(XMJob *)job;
+ (UIImage *)loadImageForKey:(NSString *)key;

@end
