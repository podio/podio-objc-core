//
//  PKCKeychain.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 10/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKCKeychain : NSObject

@property (nonatomic, copy, readonly) NSString *service;
@property (nonatomic, copy, readonly) NSString *accessGroup;

- (instancetype)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup;

+ (instancetype)keychainForService:(NSString *)service accessGroup:(NSString *)accessGroup;

- (id)objectForKey:(id)key;
- (BOOL)setObject:(id<NSCoding>)object forKey:(id)key;

- (NSData *)dataForKey:(id)key;
- (BOOL)setData:(NSData *)data forKey:(id)key;

- (BOOL)removeObjectForKey:(id)key;

@end