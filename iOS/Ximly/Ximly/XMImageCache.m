//
//  XMImageCache.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/23/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMImageCache.h"

#import "XMUtilities.h"

static NSString     *_cacheFolderPath = nil;

@implementation XMImageCache


+ (void)createCacheFolder
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:[self cacheFolderPath]]) {
        if ([fileManager createDirectoryAtPath:[self cacheFolderPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                         error:NULL]) {
            [XMUtilities addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[self cacheFolderPath]]];
        }
    }
    
}

+ (NSString *)cacheFolderPath
{
	if (!_cacheFolderPath) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *rootPath = [paths objectAtIndex:0];
        _cacheFolderPath = [rootPath stringByAppendingPathComponent:@"images"];
	}
	return _cacheFolderPath;
}

+ (NSString *)cacheFilePathForKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@/%@.png", [self cacheFolderPath], key];
}

+ (NSData *)saveImage:(UIImage *)image withKey:(NSString *)key
{
    [self createCacheFolder];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    [self saveImageData:imageData withKey:key];
    return imageData;
}

+ (void)saveImageData:(NSData *)imageData withKey:(NSString *)key
{
    if (imageData) {
        NSString *filePath = [self cacheFilePathForKey:key];
        if ([filePath length] > 0) {
            if ([imageData writeToFile:filePath atomically:YES]) {
                [XMUtilities addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:filePath]];
                NSError *error = nil;
                [[NSFileManager defaultManager] setAttributes: @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication} ofItemAtPath:filePath error:&error];
            }
        }
    }
    
}

+ (UIImage *)loadImageForKey:(NSString *)key
{
    return [UIImage imageWithContentsOfFile:[self cacheFilePathForKey:key]];
}

@end
