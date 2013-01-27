//
//  XMXimlyHTTPClient.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "AFHTTPClient.h"

@interface XMXimlyHTTPClient : AFHTTPClient

+ (XMXimlyHTTPClient *)sharedClient;

@end
