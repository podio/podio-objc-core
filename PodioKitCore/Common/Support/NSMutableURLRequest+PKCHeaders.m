//
//  NSMutableURLRequest+PKCHeaders.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 21/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSMutableURLRequest+PKCHeaders.h"
#import "NSString+PKCBase64.h"

static NSString * const kHeaderAuthorization = @"Authorization";
static NSString * const kAuthorizationOAuth2AccessTokenFormat = @"OAuth2 %@";

@implementation NSMutableURLRequest (PKCHeaders)

- (void)pkc_setAuthorizationHeaderWithOAuth2AccessToken:(NSString *)accessToken {
  NSString *value = [NSString stringWithFormat:kAuthorizationOAuth2AccessTokenFormat, accessToken];
  [self setValue:value forHTTPHeaderField:kHeaderAuthorization];
}

- (void)pkc_setAuthorizationHeaderWithUsername:(NSString *)username password:(NSString *)password {
  NSString *authString = [NSString stringWithFormat:@"%@:%@", username, password];
  [self setValue:[NSString stringWithFormat:@"Basic %@", [authString pkc_base64String]] forHTTPHeaderField:@"Authorization"];
}

@end
