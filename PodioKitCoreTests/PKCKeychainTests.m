//
//  PKCKeychainTests.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 10/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCKeychain.h"

@interface PKCKeychainTests : XCTestCase

@property (nonatomic, strong) PKCKeychain *testKeychain;

@end

@implementation PKCKeychainTests

- (void)setUp {
  [super setUp];
  
  self.testKeychain = [PKCKeychain keychainForService:@"MyService" accessGroup:@"MyApps"];
}

- (void)tearDown {
  self.testKeychain = nil;
  
  [super tearDown];
}

- (void)testInit {
  PKCKeychain *keychain = [PKCKeychain keychainForService:@"MyService" accessGroup:@"MyApps"];
  expect(keychain.service).to.equal(@"MyService");
  expect(keychain.accessGroup).to.equal(@"MyApps");
}

- (void)testSetAndGetObject {
  NSDictionary *myDict = @{@"Key1" : @"Value1",
                           @"Key2" : @"Value2"};
  
  NSString *key = [self uniqueKeyForKey:@"MyAppSecret"];
  expect([self.testKeychain objectForKey:key]).to.beNil();
  
  [self.testKeychain setObject:myDict ForKey:key];
  expect([self.testKeychain objectForKey:key]).to.equal(myDict);
}

- (void)testSetObjectWithNilKey {
  expect(^{
    [self.testKeychain setObject:@{} ForKey:nil];
  }).to.raiseAny();
}

- (void)testRemoveObject {
  NSDictionary *myDict = @{@"Key1" : @"Value1",
                           @"Key2" : @"Value2"};
  
  NSString *key = [self uniqueKeyForKey:@"MyAppSecret"];
  [self.testKeychain setObject:myDict ForKey:key];
  expect([self.testKeychain objectForKey:key]).to.equal(myDict);
  
  [self.testKeychain removeObjectForKey:key];
  expect([self.testKeychain objectForKey:key]).to.beNil();
}

- (void)testRemoveNonExistentObject {
  NSString *key = [self uniqueKeyForKey:@"MyAppSecret"];
  [self.testKeychain removeObjectForKey:key];
  expect([self.testKeychain objectForKey:key]).to.beNil();
}

#pragma mark - Helpers

- (NSString *)uniqueKeyForKey:(NSString *)key {
  // Append a unqiue identifier to the key to avoid reusing old keychain values, since the Keychain
  // is not guaranteed to be reset between unit test runs
  return [NSString stringWithFormat:@"%@-%@", key, [[NSUUID UUID] UUIDString]];
}

@end
