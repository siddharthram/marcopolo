//
//  XMImageCache.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/23/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMJob;

@interface XMImageCache : NSObject

+ (NSString *)cacheFolderPath;
+ (NSString *)cacheFilePathForKey:(NSString *)key;
+ (NSData *)saveImage:(UIImage *)image forJob:(XMJob *)job;
+ (void)saveImageData:(NSData *)imageData withKey:(NSString *)key;
+ (UIImage *)loadImageForKey:(NSString *)key;
+ (NSData *)loadImageDataForKey:(NSString *)key;

@end
