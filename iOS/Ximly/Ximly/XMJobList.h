//
//  XMJobList.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/26/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMJob.h"

#define XM_NOTIFICATION_TASK_UPDATE_DONE            @"XM_NOTIFICATION_TASK_UPDATE_DONE"


@interface XMJobList : NSObject

@property (nonatomic, readonly) NSMutableArray *jobList;

+ (XMJobList *)sharedInstance;

- (NSUInteger)count;
- (XMJob *)jobAtIndex:(NSUInteger)index;
- (void)addJob:(XMJob *)aJob;
- (void)insertJob:(XMJob *)aJob atIndex:(NSUInteger)index;
- (void)removeJob:(XMJob *)aJob;
- (void)removeAllJobs;
- (void)sortUsingDescriptors:(NSArray *)sortDescriptors;
- (void)mergeInJobsData:(NSArray *)jobsData;
- (void)submitUnsubmittedJobs;

- (void)readFromDisk;
- (void)writeToDisk;

@end
