//
//  PKCAuthenticationAPI.h
//  PodioKit
//
//  Created by Romain Briche on 28/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCBaseAPI.h"

@interface PKCAuthenticationAPI : PKCBaseAPI

+ (PKCRequest *)requestForAuthenticationWithEmail:(NSString *)email password:(NSString *)password;

+ (PKCRequest *)requestForAuthenticationWithAppID:(NSUInteger)appID token:(NSString *)appToken;

+ (PKCRequest *)requestForAuthenticationWithTransferToken:(NSString *)transferToken;

+ (PKCRequest *)requestToRefreshToken:(NSString *)refreshToken;

@end
