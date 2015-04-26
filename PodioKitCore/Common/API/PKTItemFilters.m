//
//  PKTItemFilters.m
//  PodioKitCore
//
//  Created by Sebastian Rehnby on 26/04/15.
//  Copyright (c) 2015 Citrix Systems, Inc. All rights reserved.
//

#import "PKTItemFilters.h"

@interface PKTItemFilters ()

@property (nonatomic, strong) NSMutableDictionary *values;

@end

@implementation PKTItemFilters

- (instancetype)init {
  self = [super init];
  if (!self) return nil;
  
  _values = [NSMutableDictionary new];
  
  return self;
}

#pragma mark - Public

- (instancetype)withValues:(NSArray *)values forKey:(NSString *)key {
  NSParameterAssert([values count] > 0);
  NSParameterAssert(key);
  self.values[key] = values;

  return self;
}

- (instancetype)withValue:(id)value forKey:(NSString *)key {
  // Null is equivalent to "Not set"
  id finalValue = value ?: [NSNull null];
  
  return [self withValues:@[finalValue] forKey:key];
}

- (NSDictionary *)filtersDictionary {
  return [self.values copy];
}

@end
