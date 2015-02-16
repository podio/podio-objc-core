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

@interface PKCRequestSerializer : NSObject

@property (nonatomic, copy, readonly) NSDictionary *additionalHTTPHeaders;

- (NSMutableURLRequest *)URLRequestForRequest:(PKCRequest *)request relativeToURL:(NSURL *)baseURL;
- (NSMutableURLRequest *)URLRequestForRequest:(PKCRequest *)request multipartData:(PKCMultipartFormData *)multipartData relativeToURL:(NSURL *)baseURL;

- (void)setValue:(NSString *)value forHTTPHeader:(NSString *)header;
- (void)setAuthorizationHeaderWithOAuth2AccessToken:(NSString *)accessToken;
- (void)setAuthorizationHeaderWithAPIKey:(NSString *)key secret:(NSString *)secret;

- (PKCMultipartFormData *)multipartFormDataFromRequest:(PKCRequest *)request;

@end
