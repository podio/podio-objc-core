//
//  PKCKeychainTokenStore.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 10/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKCTokenStore.h"

@class PKCKeychain;

@interface PKCKeychainTokenStore : NSObject <PKCTokenStore>

@property (nonatomic, strong, readonly) PKCKeychain *keychain;

- (instancetype)initWithService:(NSString *)service;

- (instancetype)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup;

- (instancetype)initWithKeychain:(PKCKeychain *)keychain;

@end
