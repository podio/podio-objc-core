//
//  PKCKeychainTokenStore.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 10/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCKeychainTokenStore.h"
#import "PKCKeychain.h"

static NSString * const kTokenKeychainKey = @"PodioKitOAuthToken";

@interface PKCKeychainTokenStore ()

@end

@implementation PKCKeychainTokenStore

- (instancetype)initWithService:(NSString *)service {
  return [self initWithService:service accessGroup:nil];
}

- (instancetype)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup {
  PKCKeychain *keychain = [PKCKeychain keychainForService:service accessGroup:accessGroup];
  return [self initWithKeychain:keychain];
}

- (instancetype)initWithKeychain:(PKCKeychain *)keychain {
  self = [super init];
  if (!self) return nil;
  
  _keychain = keychain;
  
  return self;
}

#pragma mark - PKCTokenStore

- (void)storeToken:(PKCOAuth2Token *)token {
  [self.keychain setObject:token forKey:kTokenKeychainKey];
}

- (void)deleteStoredToken {
  [self.keychain removeObjectForKey:kTokenKeychainKey];
}

- (PKCOAuth2Token *)storedToken {
  return [self.keychain objectForKey:kTokenKeychainKey];
}

@end
