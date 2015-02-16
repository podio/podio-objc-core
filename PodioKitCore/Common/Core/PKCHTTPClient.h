//
//  PKCClient.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 16/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCRequest.h"
#import "PKCResponse.h"
#import "PKCRequestSerializer.h"
#import "PKCResponseSerializer.h"

/**
 *  A handler block to which the response or error of a request will be passed.
 *
 *  @param response The response, if the request was successful
 *  @param error    Any error that occurred while performing the request, e.g. an HTTP error or some other error.
 */
typedef void(^PKCRequestCompletionBlock)(PKCResponse *response, NSError *error);

@interface PKCHTTPClient : NSObject

/**
 *  The base URL for the API endpoint. The default is https://api.podio.com.
 */
@property (nonatomic, copy) NSURL *baseURL;

/**
 *  The serializer of the request.
 */
@property (nonatomic, strong, readonly) PKCRequestSerializer *requestSerializer;

/**
 *  The serializer of the response.
 */
@property (nonatomic, strong, readonly) PKCResponseSerializer *responseSerializer;

/**
 *  Controls whether or not to pin the server public key to that of any .cer certificate included in the app bundle.
 */
@property (nonatomic) BOOL useSSLPinning;

/**
 *  Creates and returns a NSURLSessionTask for the given request, for which the provided completion handler
 *  will be executed upon completion.
 *
 *  @param request    The request
 *  @param completion A completion handler to be executed on task completion.
 *
 *  @return An NSURLSessionTask
 */
- (NSURLSessionTask *)taskForRequest:(PKCRequest *)request completion:(PKCRequestCompletionBlock)completion;

@end
