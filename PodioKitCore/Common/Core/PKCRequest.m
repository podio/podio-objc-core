
//
//  PKCRequest.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 16/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCRequest.h"

@implementation PKCRequest

- (instancetype)initWithPath:(NSString *)path url:(NSURL *)url parameters:(NSDictionary *)parameters method:(PKCRequestMethod)method {
  self = [super init];
  if (!self) return nil;
  
  _path = [path copy];
  _URL = [url copy];
  _parameters = [parameters copy];
  _method = method;
  
  return self;
}

+ (instancetype)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters method:(PKCRequestMethod)method {
  return [[self alloc] initWithPath:path url:nil parameters:parameters method:method];
}

+ (instancetype)requestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters method:(PKCRequestMethod)method {
  return [[self alloc] initWithPath:nil url:url parameters:parameters method:method];
}

+ (instancetype)GETRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self requestWithPath:path parameters:parameters method:PKCRequestMethodGET];
}

+ (instancetype)POSTRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self requestWithPath:path parameters:parameters method:PKCRequestMethodPOST];
}

+ (instancetype)PUTRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self requestWithPath:path parameters:parameters method:PKCRequestMethodPUT];
}

+ (instancetype)DELETERequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters {
  return [self requestWithPath:path parameters:parameters method:PKCRequestMethodDELETE];
}

+ (instancetype)GETRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters {
  return [self requestWithURL:url parameters:parameters method:PKCRequestMethodGET];
}

+ (instancetype)POSTRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters {
  return [self requestWithURL:url parameters:parameters method:PKCRequestMethodPOST];
}

+ (instancetype)PUTRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters {
  return [self requestWithURL:url parameters:parameters method:PKCRequestMethodPUT];
}

+ (instancetype)DELETERequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters {
  return [self requestWithURL:url parameters:parameters method:PKCRequestMethodDELETE];
}

@end
