//
//  PKCHTTPStubs.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 16/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "PKCHTTPStubs.h"

@implementation PKCHTTPStubs

+ (void)stubResponseForPath:(NSString *)path block:(void (^)(PKCHTTPStubber *stubber))block {
  PKCHTTPStubber *stubber = [PKCHTTPStubber stubberForPath:path];
  
  if (block) block(stubber);
  
  [stubber stub];
}

+ (void)stubResponseForPath:(NSString *)path responseObject:(id)responseObject {
  return [self stubResponseForPath:path block:^(PKCHTTPStubber *stubber) {
    stubber.responseObject = responseObject;
  }];
}

+ (void)stubResponseForPath:(NSString *)path statusCode:(int)statusCode {
  return [self stubResponseForPath:path block:^(PKCHTTPStubber *stubber) {
    stubber.statusCode = statusCode;
  }];
}

+ (void)stubResponseForPath:(NSString *)path requestTime:(int)requestTime responseTime:(int)responseTime {
  return [self stubResponseForPath:path block:^(PKCHTTPStubber *stubber) {
    stubber.requestTime = requestTime;
    stubber.responseTime = responseTime;
  }];
}

+ (void)stubNetworkDownForPath:(NSString *)path {
  return [self stubResponseForPath:path block:^(PKCHTTPStubber *stubber) {
    stubber.error = [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil];
  }];
}

@end
