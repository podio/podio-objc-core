//
//  PKCRequest.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 16/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKCRequestFileData.h"

#define PKCRequestPath(fmt, ...) [NSString stringWithFormat:fmt, ##__VA_ARGS__]

typedef NSURLRequest * (^PKCURLRequestConfigurationBlock) (NSURLRequest *request);

typedef NS_ENUM(NSUInteger, PKCRequestMethod) {
  PKCRequestMethodGET = 0,
  PKCRequestMethodPOST,
  PKCRequestMethodPUT,
  PKCRequestMethodDELETE,
  PKCRequestMethodHEAD,
};

typedef NS_ENUM(NSUInteger, PKCRequestContentType) {
  PKCRequestContentTypeJSON = 0,
  PKCRequestContentTypeFormURLEncoded,
  PKCRequestContentTypeMultipart
};

@interface PKCRequest : NSObject

@property (nonatomic, assign, readonly) PKCRequestMethod method;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSDictionary *parameters;
@property (nonatomic, strong) PKCRequestFileData *fileData;
@property (nonatomic, assign, readwrite) PKCRequestContentType contentType;
@property (nonatomic, copy, readwrite) PKCURLRequestConfigurationBlock URLRequestConfigurationBlock;

+ (instancetype)GETRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters;
+ (instancetype)POSTRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters;
+ (instancetype)PUTRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters;
+ (instancetype)DELETERequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters;

+ (instancetype)GETRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters;
+ (instancetype)POSTRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters;
+ (instancetype)PUTRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters;
+ (instancetype)DELETERequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters;

@end
