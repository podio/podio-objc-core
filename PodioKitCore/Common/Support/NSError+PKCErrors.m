//
//  NSError+PKCErrors.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 11/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSError+PKCErrors.h"
#import "NSDictionary+PKCAdditions.h"

NSString * const PodioServerErrorDomain = @"PodioServerErrorDomain";

NSString * const PKCErrorKey = @"PKCError";
NSString * const PKCErrorDescriptionKey = @"PKCErrorDescription";
NSString * const PKCErrorDetailKey = @"PKCErrorDetail";
NSString * const PKCErrorParametersKey = @"PKCErrorParameters";
NSString * const PKCErrorPropagateKey = @"PKCErrorPropagate";

@implementation NSError (PKCErrors)

#pragma mark - Public

+ (NSError *)pkc_serverErrorWithStatusCode:(NSUInteger)statusCode body:(id)body {
  return [NSError errorWithDomain:PodioServerErrorDomain code:statusCode userInfo:[self pkc_userInfoFromBody:body]];
}

- (BOOL)pkc_isServerError {
  return [self.domain isEqualToString:PodioServerErrorDomain] && self.code > 0;
}

- (NSString *)pkc_localizedServerSideDescription {
  return [self pkc_shouldPropagate] ? self.userInfo[PKCErrorDescriptionKey] : nil;
}

#pragma mark - Private

- (BOOL)pkc_shouldPropagate {
  return [self pkc_isServerError] && [self.userInfo[PKCErrorPropagateKey] boolValue] == YES;
}

+ (NSDictionary *)pkc_userInfoFromBody:(id)body {
  if (![body isKindOfClass:[NSDictionary class]]) return nil;
  
  NSDictionary *errorDict = body;
  
  NSMutableDictionary *userInfo = [NSMutableDictionary new];
  
  NSString *error = [errorDict pkc_nonNullObjectForKey:@"error"];
  NSString *errorDescription = [errorDict pkc_nonNullObjectForKey:@"error_description"];
  NSString *errorDetail = [errorDict pkc_nonNullObjectForKey:@"error_detail"];
  NSDictionary *errorParameters = [errorDict pkc_nonNullObjectForKey:@"error_parameters"];
  NSNumber *errorPropagate = [errorDict pkc_nonNullObjectForKey:@"error_propagate"];
  
  if (errorDescription && [errorPropagate boolValue]) userInfo[NSLocalizedDescriptionKey] = errorDescription;
  if (error) userInfo[PKCErrorKey] = error;
  if (errorDescription) userInfo[PKCErrorDescriptionKey] = errorDescription;
  if (errorDetail) userInfo[PKCErrorDetailKey] = errorDetail;
  if (errorParameters) userInfo[PKCErrorParametersKey] = errorParameters;
  if (errorPropagate) userInfo[PKCErrorPropagateKey] = errorPropagate;
  
  return [userInfo copy];
}

@end
