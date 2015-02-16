//
//  PKCHTTPStubs.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 16/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKCHTTPStubber.h"

@interface PKCHTTPStubs : NSObject

+ (void)stubResponseForPath:(NSString *)path block:(void (^)(PKCHTTPStubber *stubber))block;

+ (void)stubResponseForPath:(NSString *)path responseObject:(id)responseObject;
+ (void)stubResponseForPath:(NSString *)path statusCode:(int)statusCode;
+ (void)stubResponseForPath:(NSString *)path requestTime:(int)requestTime responseTime:(int)responseTime;
+ (void)stubNetworkDownForPath:(NSString *)path;

@end
