//
//  XMImageCache.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/23/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMImageCache : NSObject

+ (void)saveImage:(UIImage *)image withKey:(NSString *)key;
+ (UIImage *)loadImageForKey:(NSString *)key;

@end
