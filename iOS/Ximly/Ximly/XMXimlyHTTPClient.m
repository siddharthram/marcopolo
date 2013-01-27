//
//  XMXimlyHTTPClient.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMXimlyHTTPClient.h"

#import "AFJSONRequestOperation.h"

static NSString * const kXimlyBaseURLString = @"https://TODO";

@implementation XMXimlyHTTPClient

+ (XMXimlyHTTPClient *)sharedClient {
    static XMXimlyHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[XMXimlyHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kXimlyBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end
