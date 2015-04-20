//
//  NSError+PKCErrors.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 11/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const PodioServerErrorDomain;

extern NSString * const PKCErrorKey;
extern NSString * const PKCErrorDescriptionKey;
extern NSString * const PKCErrorDetailKey;
extern NSString * const PKCErrorParametersKey;
extern NSString * const PKCErrorPropagateKey;

@interface NSError (PKCErrors)

+ (NSError *)pkc_serverErrorWithStatusCode:(NSUInteger)statusCode body:(id)body;

- (BOOL)pkc_isServerError;

- (NSString *)pkc_localizedServerSideDescription;

@end
