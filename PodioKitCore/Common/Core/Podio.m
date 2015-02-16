//
//  Podio.m
//  PodioKitCore
//
//  Created by Sebastian Rehnby on 16/02/15.
//  Copyright (c) 2015 Citrix Systems, Inc. All rights reserved.
//

#import "Podio.h"
#import "PKCClient.h"
#import "PKCKeychainTokenStore.h"

@implementation Podio

+ (void)setupWithAPIKey:(NSString *)key secret:(NSString *)secret {
  [[PKCClient currentClient] setupWithAPIKey:key secret:secret];
}

+ (PKCAsyncTask *)authenticateAsUserWithEmail:(NSString *)email password:(NSString *)password {
  return [[PKCClient currentClient] authenticateAsUserWithEmail:email password:password];
}

+ (PKCAsyncTask *)authenticateAsAppWithID:(NSUInteger)appID token:(NSString *)appToken {
  return [[PKCClient currentClient] authenticateAsAppWithID:appID token:appToken];
}

+ (void)authenticateAutomaticallyAsAppWithID:(NSUInteger)appID token:(NSString *)appToken {
  [[PKCClient currentClient] authenticateAutomaticallyAsAppWithID:appID token:appToken];
}

+ (BOOL)isAuthenticated {
  return [[PKCClient currentClient] isAuthenticated];
}

+ (void)automaticallyStoreTokenInKeychainForServiceWithName:(NSString *)name {
  [PKCClient currentClient].tokenStore = [[PKCKeychainTokenStore alloc] initWithService:name];
  [[PKCClient currentClient] restoreTokenIfNeeded];
}

+ (void)automaticallyStoreTokenInKeychainForCurrentApp {
  NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge id)kCFBundleIdentifierKey];
  [self automaticallyStoreTokenInKeychainForServiceWithName:name];
}

@end
