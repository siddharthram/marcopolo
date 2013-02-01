//
//  XMJobList.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/26/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMJobList.h"

#import "XMImageCache.h"
#import "XMUtilities.h"


static NSString     *_dataFilePath = nil;

#define kDummyKey1 @"DummyKey1"
#define kDummyKey2 @"DummyKey2"
#define kDummyKey3 @"DummyKey3"
#define kDummyKey4 @"DummyKey4"


@interface XMJobList ()

@property (nonatomic, readwrite) NSMutableArray *jobList;

@end

@implementation XMJobList

+ (XMJobList *)sharedInstance {
    static XMJobList *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[XMJobList alloc] init];
    });
    
    return _sharedInstance;
}

+ (NSString *)dataFilePath
{
	if (!_dataFilePath) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *dataDirectory = [paths objectAtIndex:0];
        if ([dataDirectory length] > 0) {
            _dataFilePath = [NSString stringWithFormat:@"%@/JobList", dataDirectory];
        }
	}
	return _dataFilePath;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self readFromDisk];
    }
    
    return self;
}

- (NSUInteger)count
{
    return [self.jobList count];
}

- (XMJob *)jobAtIndex:(NSUInteger)index
{
    return (XMJob *)[self.jobList objectAtIndex:index];
}

- (void)addJob:(XMJob *)aJob
{
    [self.jobList addObject:aJob];
}

- (void)insertJob:(XMJob *)aJob atIndex:(NSUInteger)index
{
    [self.jobList insertObject:aJob atIndex:index];
}

- (void)removeJob:(XMJob *)aJob
{
    [self.jobList removeObject:aJob];
}

- (void)removeAllJobs
{
    [self.jobList removeAllObjects];
}

- (void)sortUsingDescriptors:(NSArray *)sortDescriptors
{
    [self.jobList sortUsingDescriptors:sortDescriptors];
}

- (void)readFromDisk
{
    
    BOOL saveTestData = NO;
    
    NSArray *listFromDisk = [NSMutableArray arrayWithContentsOfFile:[XMJobList dataFilePath]];
    
    /*
    if ([listFromDisk count] == 0) {
        // This data is for testing purposes only
        [XMImageCache saveImage:[UIImage imageNamed:@"sample1.jpg"] withKey:kDummyKey1];
        [XMImageCache saveImage:[UIImage imageNamed:@"sample2.jpg"] withKey:kDummyKey2];
        [XMImageCache saveImage:[UIImage imageNamed:@"sample3.jpg"] withKey:kDummyKey3];
        [XMImageCache saveImage:[UIImage imageNamed:@"sample4.jpg"] withKey:kDummyKey4];

        listFromDisk = [@[[@{kJobRequestIDKey : kDummyKey1, kJobStatusKey : @"PROCESSING",  kJobSubmissionTimeKey : [NSDate dateWithTimeIntervalSinceNow:-1200]} mutableCopy],
                        [@{kJobRequestIDKey : kDummyKey2, kJobStatusKey : @"DONE!", kJobFinishTimeKey : [NSDate dateWithTimeIntervalSinceNow:-1500], kJobTranscriptionKey : @"Blah blah blah blah.  Blah blah blah blah blah.  Blah blah blah blah blah blah blah blah blah blah.", kJobRatingKey : @"Good", kJobRatingCommentKey : @"Wow! Better than sliced bread."} mutableCopy],
                        [@{kJobRequestIDKey : kDummyKey3, kJobStatusKey : @"DONE!", kJobFinishTimeKey : [NSDate dateWithTimeIntervalSinceNow:-180000], kJobTranscriptionKey : @"Gobbledygook gobbledygook gobbledygook gobbledygook.  Blah blah gobbledygook blah blah.  Gobbledygook blah blah gobbledygook blah blah blah blah blah blah."} mutableCopy],
                        [@{kJobRequestIDKey : kDummyKey4, kJobTitleKey : @"Whiteboard in San Jose", kJobFinishTimeKey : [NSDate dateWithTimeIntervalSinceNow:-192100], kJobTranscriptionKey : @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."} mutableCopy]] mutableCopy];
        saveTestData = YES;
    }
     */
    
    self.jobList = [NSMutableArray arrayWithCapacity:[listFromDisk count]];
    
    for (NSMutableDictionary *jobData in listFromDisk) {
        XMJob *job = [XMJob new];
        job.jobData = jobData;
        [self.jobList addObject:job];
    }
    
    if (saveTestData) {
        [self writeToDisk];
    }
}

- (void)writeToDisk
{
    NSString *filePath = [XMJobList dataFilePath];
    
    NSMutableArray *listToWrite = [NSMutableArray arrayWithCapacity:[self.jobList count]];
    
    // We're doing this instead of using NSKeyedArchiver for the sake of performance
    for (XMJob *job in self.jobList) {
        [listToWrite addObject:job.jobData];
    }
    
    [listToWrite writeToFile:filePath atomically:YES];
    
    [XMUtilities addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:filePath]];
    NSError *error = nil;
    [[NSFileManager defaultManager] setAttributes: @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication} ofItemAtPath:filePath error:&error];
}

- (NSArray *)defaultSortDescriptors
{
    NSSortDescriptor *sortDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"submissionTime" ascending:NO];
	return [NSArray arrayWithObject:sortDescriptor];
}

- (void)mergeInJobsData:(NSArray *)jobsData
{
    NSMutableDictionary *jobsMap = [NSMutableDictionary dictionaryWithCapacity:[self.jobList count]];
    XMJob *oldJob = nil;
    
    for (oldJob in self.jobList) {
        [jobsMap setValue:oldJob forKey:oldJob.requestID];
    }
    
    for (NSDictionary *newJobData in jobsData) {
        oldJob = [jobsMap valueForKey:[newJobData valueForKey:kJobRequestIDKey]];
        if (oldJob) {
            [oldJob populateObjectFromServerJSON:newJobData];
        } else {
            XMJob *newJob = [XMJob new];
            [newJob populateObjectFromServerJSON:newJobData];
            [self.jobList addObject:newJob];
        }
    }

    [self sortUsingDescriptors:[self defaultSortDescriptors]];
    
    [self writeToDisk];
}

@end
