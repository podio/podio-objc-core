//
//  PKCAuthenticationAPI.m
//  PodioKit
//
//  Created by Romain Briche on 28/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCAuthenticationAPI.h"

static NSString * const kAuthenticationPath = @"/oauth/token";

static NSString * const kAuthenticationGrantTypeKey = @"grant_type";
static NSString * const kAuthenticationUsernameKey = @"username";
static NSString * const kAuthenticationPasswordKey = @"password";
static NSString * const kAuthenticationAppIDKey = @"app_id";
static NSString * const kAuthenticationAppTokenKey = @"app_token";
static NSString * const kAuthenticationrRefreshTokenKey = @"refresh_token";

static NSString * const kAuthenticationGrantTypePassword = @"password";
static NSString * const kAuthenticationGrantTypeApp = @"app";
static NSString * const kAuthenticationGrantTypeRefreshToken = @"refresh_token";

@implementation PKCAuthenticationAPI

+ (PKCRequest *)requestForAuthenticationWithEmail:(NSString *)email password:(NSString *)password {
  NSParameterAssert(email);
  NSParameterAssert(password);

  return [self requestForAuthenticationWithGrantType:kAuthenticationGrantTypePassword parameters:@{kAuthenticationUsernameKey: email, kAuthenticationPasswordKey: password}];
}

+ (PKCRequest *)requestForAuthenticationWithAppID:(NSUInteger)appID token:(NSString *)appToken {
  NSParameterAssert(appID);
  NSParameterAssert(appToken);

  return [self requestForAuthenticationWithGrantType:kAuthenticationGrantTypeApp parameters:@{kAuthenticationAppIDKey: @(appID), kAuthenticationAppTokenKey: appToken}];
}

+ (PKCRequest *)requestToRefreshToken:(NSString *)refreshToken {
  NSParameterAssert(refreshToken);

  return [self requestForAuthenticationWithGrantType:kAuthenticationGrantTypeRefreshToken parameters:@{kAuthenticationrRefreshTokenKey: refreshToken}];
}

#pragma mark - Private

+ (PKCRequest *)requestForAuthenticationWithGrantType:(NSString *)grantType parameters:(NSDictionary *)parameters {
  NSParameterAssert(grantType);
  NSParameterAssert(parameters);

  NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:parameters];
  body[kAuthenticationGrantTypeKey] = grantType;

  PKCRequest *request = [PKCRequest POSTRequestWithPath:kAuthenticationPath parameters:[body copy]];
  request.contentType = PKCRequestContentTypeFormURLEncoded;
  
  return request;
}

@end
