//
//  XMAttachmentCache.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 5/19/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMJob;

@interface XMAttachmentCache : NSObject

+ (NSString *)cacheFolderName;
+ (NSString *)cacheFolderPath;
+ (NSString *)cacheFilePathForKey:(NSString *)key;
+ (BOOL)cacheFileExistsForKey:(NSString *)key;
+ (void)saveAttachmentData:(NSData *)attachmentData withKey:(NSString *)key;
+ (NSData *)loadAttachmentDataForKey:(NSString *)key;
+ (void)deleteCache;

@end
