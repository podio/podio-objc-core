//
//  PKCOAuth2TokenTests.m
//  PodioKit
//
//  Created by Romain Briche on 28/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCOAuth2Token.h"

@interface PKCOAuth2TokenTests : XCTestCase

@end

@implementation PKCOAuth2TokenTests

- (void)testTokenFromDictionary {
  NSDictionary *dictionary = @{
    @"access_token": @"some_token",
    @"refresh_token": @"some_other_token",
    @"expires_in": @1234,
    @"ref": @{@"test": @"value"}
  };

  PKCOAuth2Token *token = [[PKCOAuth2Token alloc] initWithDictionary:dictionary];

  expect(token.accessToken).to.equal(dictionary[@"access_token"]);
  expect(token.refreshToken).to.equal(dictionary[@"refresh_token"]);
  expect([token.expiresOn timeIntervalSince1970]).to.beCloseToWithin([[NSDate date] timeIntervalSince1970] + [dictionary[@"expires_in"] doubleValue], 1);
  expect(token.refData).to.equal(dictionary[@"ref"]);
}

- (void)testWillExpireInTrue {
  PKCOAuth2Token *token = [self tokenWithExpirationIntervalFromNow:100];
  expect([token willExpireWithinIntervalFromNow:1000]).to.beTruthy();
}

- (void)testWillExpireInFalse {
  PKCOAuth2Token *token = [self tokenWithExpirationIntervalFromNow:100];
  expect([token willExpireWithinIntervalFromNow:10]).to.beFalsy();
}

#pragma mark - Helpers

- (PKCOAuth2Token *)tokenWithExpirationIntervalFromNow:(NSTimeInterval)expiresIn {
  NSDictionary *dictionary = @{
      @"access_token": @"some_token",
      @"refresh_token": @"some_other_token",
      @"expires_in": @(expiresIn),
      @"ref": @{@"test": @"value"}
    };
  
  return [[PKCOAuth2Token alloc] initWithDictionary:dictionary];
}

@end
