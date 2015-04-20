//
//  PKCOAuth2Token.m
//  PodioKit
//
//  Created by Romain Briche on 28/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCOAuth2Token.h"
#import "NSValueTransformer+PKCTransformers.h"

@implementation PKCOAuth2Token

- (instancetype)initWithAccessToken:(NSString *)accessToken
                       refreshToken:(NSString *)refreshToken
                      transferToken:(NSString *)transferToken
                          expiresOn:(NSDate *)expiresOn
                            refData:(NSDictionary *)refData {
  self = [super init];
  if (!self) return nil;
  
  _accessToken = [accessToken copy];
  _refreshToken = [refreshToken copy];
  _transferToken = [transferToken copy];
  _expiresOn = [expiresOn copy];
  _refData = [refData copy];
  
  return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[self class]]) return NO;
  
  return [self.accessToken isEqualToString:[object accessToken]];
}

- (NSUInteger)hash {
  return [self.accessToken hash];
}

#pragma mark - PKCModel

+ (NSDictionary *)dictionaryKeyPathsForPropertyNames {
  return @{
    @"accessToken": @"access_token",
    @"refreshToken": @"refresh_token",
    @"transferToken": @"transfer_token",
    @"expiresOn": @"expires_in",
    @"refData": @"ref",
  };
}

+ (NSValueTransformer *)expiresOnValueTransformer {
  return [NSValueTransformer pkc_transformerWithBlock:^id(NSNumber *expiresIn) {
    return [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
  }];
}

#pragma mark - Public

- (BOOL)willExpireWithinIntervalFromNow:(NSTimeInterval)expireInterval {
  NSDate *date = [NSDate dateWithTimeIntervalSinceNow:expireInterval];
  return [self.expiresOn earlierDate:date] == self.expiresOn;
}

@end
