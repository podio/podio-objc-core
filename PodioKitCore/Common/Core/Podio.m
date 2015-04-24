//
//  Podio.m
//  PodioKitCore
//
//  Created by Sebastian Rehnby on 16/02/15.
//  Copyright (c) 2015 Citrix Systems, Inc. All rights reserved.
//

#import "Podio.h"
#import "PKTClient.h"
#import "PKTKeychainTokenStore.h"

@implementation Podio

+ (void)setupWithAPIKey:(NSString *)key secret:(NSString *)secret {
  [[PKTClient currentClient] setupWithAPIKey:key secret:secret];
}

+ (PKTAsyncTask *)authenticateAsUserWithEmail:(NSString *)email password:(NSString *)password {
  return [[PKTClient currentClient] authenticateAsUserWithEmail:email password:password];
}

+ (PKTAsyncTask *)authenticateAsAppWithID:(NSUInteger)appID token:(NSString *)appToken {
  return [[PKTClient currentClient] authenticateAsAppWithID:appID token:appToken];
}

+ (void)authenticateAutomaticallyAsAppWithID:(NSUInteger)appID token:(NSString *)appToken {
  [[PKTClient currentClient] authenticateAutomaticallyAsAppWithID:appID token:appToken];
}

+ (BOOL)isAuthenticated {
  return [[PKTClient currentClient] isAuthenticated];
}

+ (void)automaticallyStoreTokenInKeychainForServiceWithName:(NSString *)name {
  [PKTClient currentClient].tokenStore = [[PKTKeychainTokenStore alloc] initWithService:name];
  [[PKTClient currentClient] restoreTokenIfNeeded];
}

+ (void)automaticallyStoreTokenInKeychainForCurrentApp {
  NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge id)kCFBundleIdentifierKey];
  [self automaticallyStoreTokenInKeychainForServiceWithName:name];
}

@end
