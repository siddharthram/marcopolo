//
//  XMUtilities.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/23/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMUtilities : NSObject

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+ (CGFloat)heightOfScreen;

+ (NSString *)timeAgoFromUnixTime:(double)seconds;

@end
