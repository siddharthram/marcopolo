//
//  XMAttachmentCache.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 5/19/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMAttachmentCache.h"

#import "XMJob.h"
#import "XMUtilities.h"

static NSString     *_cacheFolderPath = nil;

@implementation XMAttachmentCache


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
        _cacheFolderPath = [rootPath stringByAppendingPathComponent:[self cacheFolderName]];
	}
	return _cacheFolderPath;
}

+ (NSString *)cacheFolderName
{
    return @"attachments";
}


+ (NSString *)cacheFilePathForKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@/%@", [self cacheFolderPath], key];
}

+ (BOOL)cacheFileExistsForKey:(NSString *)key
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    return [fileManager fileExistsAtPath:[self cacheFilePathForKey:key]];
}

+ (void)saveAttachmentData:(NSData *)attachmentData withKey:(NSString *)key
{
    [self createCacheFolder];
    if (attachmentData) {
        NSString *filePath = [self cacheFilePathForKey:key];
        if ([filePath length] > 0) {
            if ([attachmentData writeToFile:filePath atomically:YES]) {
                [XMUtilities addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:filePath]];
                NSError *error = nil;
                [[NSFileManager defaultManager] setAttributes: @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication} ofItemAtPath:filePath error:&error];
            }
        }
    }
    
}

+ (NSData *)loadAttachmentDataForKey:(NSString *)key
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
