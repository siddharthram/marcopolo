//
//  XMImageCache.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/23/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMImageCache.h"

static NSString     *_cacheFolderPath = nil;

@implementation XMImageCache

+ (NSString *)newKey
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

+ (NSString *)cacheFolderPath
{
	if (!_cacheFolderPath) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_cacheFolderPath = [paths objectAtIndex:0];
	}
	return _cacheFolderPath;
}

+ (NSString *)cacheFilePathForKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@/%@.png", [self cacheFolderPath], key];
}

+ (void)saveImage:(UIImage *)image withKey:(NSString *)key
{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *filePath = [self cacheFilePathForKey:key];
    [imageData writeToFile:filePath atomically:YES];
    NSError *error = nil;
    [[NSFileManager defaultManager] setAttributes: @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication} ofItemAtPath:filePath error:&error];
}

+ (UIImage *)loadImageForKey:(NSString *)key
{
    return [UIImage imageWithContentsOfFile:[self cacheFilePathForKey:key]];
}

@end
