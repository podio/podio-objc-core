//
//  NSMutableURLRequest+PKCHeaders.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 21/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (PKCHeaders)

- (void)pkc_setAuthorizationHeaderWithOAuth2AccessToken:(NSString *)accessToken;
- (void)pkc_setAuthorizationHeaderWithUsername:(NSString *)username password:(NSString *)password;

@end
