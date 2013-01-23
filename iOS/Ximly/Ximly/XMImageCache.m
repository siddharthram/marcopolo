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

+ (NSString *)newKey
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

+ (void)createCacheFolder
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:[self cacheFolderPath]]) {
        [fileManager createDirectoryAtPath:[self cacheFolderPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
        [XMUtilities addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:[self cacheFolderPath]]];
    }
    
}

+ (NSString *)cacheFolderPath
{
	if (!_cacheFolderPath) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *rootPath = [paths objectAtIndex:0];
        _cacheFolderPath = [NSString stringWithFormat:@"%@/images", rootPath];
	}
	return _cacheFolderPath;
}

+ (NSString *)cacheFilePathForKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@/%@.png", [self cacheFolderPath], key];
}

+ (void)saveImage:(UIImage *)image withKey:(NSString *)key
{
    [self createCacheFolder];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *filePath = [self cacheFilePathForKey:key];
    [imageData writeToFile:filePath atomically:YES];
    
    [XMUtilities addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:filePath]];
    NSError *error = nil;
    [[NSFileManager defaultManager] setAttributes: @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication} ofItemAtPath:filePath error:&error];
}

+ (UIImage *)loadImageForKey:(NSString *)key
{
    return [UIImage imageWithContentsOfFile:[self cacheFilePathForKey:key]];
}

@end
