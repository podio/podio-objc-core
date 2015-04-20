//
//  PKCRequestSerializer.h
//  PodioKit
//
//  Created by Romain Briche on 22/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKCRequest;

@class PKCMultipartFormData;

extern NSString * const PKCRequestSerializerHTTPHeaderKeyAuthorization;
extern NSString * const PKCRequestSerializerHTTPHeaderKeyUserAgent;
extern NSString * const PKCRequestSerializerHTTPHeaderKeyContentType;
extern NSString * const PKCRequestSerializerHTTPHeaderKeyContentLength;

@interface PKCRequestSerializer : NSObject

- (NSMutableURLRequest *)URLRequestForRequest:(PKCRequest *)request relativeToURL:(NSURL *)baseURL;
- (NSMutableURLRequest *)URLRequestForRequest:(PKCRequest *)request multipartData:(PKCMultipartFormData *)multipartData relativeToURL:(NSURL *)baseURL;

- (id)valueForHTTPHeader:(NSString *)header;

- (void)setValue:(NSString *)value forHTTPHeader:(NSString *)header;
- (void)setAuthorizationHeaderWithOAuth2AccessToken:(NSString *)accessToken;
- (void)setAuthorizationHeaderWithAPIKey:(NSString *)key secret:(NSString *)secret;
- (void)setUserAgentHeader:(NSString *)userAgent;

- (PKCMultipartFormData *)multipartFormDataFromRequest:(PKCRequest *)request;

@end
