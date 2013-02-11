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
    return [NSString stringWithFormat:@"%@/%@", [self cacheFolderPath], key];
}

+ (NSData *)saveImage:(UIImage *)image forJob:(XMJob *)job
{
    
    UIImage *resizedImage = [UIImage shrink:image toMaxSide:800];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.6);
    [self saveImageData:imageData withKey:job.imageKey];
    
    resizedImage = [UIImage shrink:image toMaxSide:100];
    NSData *thumbnailData = UIImageJPEGRepresentation(resizedImage, 0.6);
    [self saveImageData:thumbnailData withKey:job.thumbnailKey];
    
    return imageData;
}

+ (void)saveImageData:(NSData *)imageData withKey:(NSString *)key
{
    [self createCacheFolder];
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

+ (NSData *)loadImageDataForKey:(NSString *)key
{
    return [NSData dataWithContentsOfFile:[self cacheFilePathForKey:key]];
}

+ (void)deleteCache
{
    NSFileManager *fileMgr = [NSFileManager new];
    NSError *error = nil;
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:[self cacheFolderPath] error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [[self cacheFolderPath] stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
            if (!removeSuccess) {
                // TODO
            }
        }
    } else {
        // TODO
    }
}

@end
