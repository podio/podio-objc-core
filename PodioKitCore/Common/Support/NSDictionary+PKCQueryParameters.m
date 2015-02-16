//
//  NSDictionary+PKCQueryParameters.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 09/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSDictionary+PKCQueryParameters.h"
#import "NSString+PKCURLEncode.h"
#import "NSArray+PKCAdditions.h"

@implementation NSDictionary (PKCQueryParameters)

- (NSString *)pkc_queryString {
  return [self pkc_queryStringByEscapingValues:NO];
}

- (NSString *)pkc_escapedQueryString {
  return [self pkc_queryStringByEscapingValues:YES];
}

- (NSDictionary *)pkc_queryParametersPairs {
  return [self pkc_flattenedKeysAndValuesWithKeyMappingBlock:nil];
}

- (NSDictionary *)pkc_escapedQueryParametersPairs {
  NSMutableDictionary *escapedPairs = [NSMutableDictionary new];
  
  NSDictionary *pairs = [self pkc_queryParametersPairs];
  [pairs enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
    NSString *stringValue = [value isKindOfClass:[NSString class]] ? value : [NSString stringWithFormat:@"%@", value];
    escapedPairs[key] = [stringValue pkc_encodeString];
  }];
  
  return [escapedPairs copy];
}

#pragma mark - Private

- (NSDictionary *)pkc_flattenedKeysAndValuesWithKeyMappingBlock:(NSString * (^)(id key))keyMappingBlock {
  NSMutableDictionary *pairs = [NSMutableDictionary new];
  
  [self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
    NSString *currentKey = keyMappingBlock ? keyMappingBlock(key) : key;
    
    if ([value isKindOfClass:[NSDictionary class]]) {
      NSDictionary *subKeysAndValues = [value pkc_flattenedKeysAndValuesWithKeyMappingBlock:^NSString *(id subKey) {
        // Sub-keys should appear in brackets
        return [NSString stringWithFormat:@"[%@]", subKey];
      }];
      
      [subKeysAndValues enumerateKeysAndObjectsUsingBlock:^(id subKey, id subValue, BOOL *stop) {
        NSString *fullKey = [currentKey stringByAppendingString:subKey];
        pairs[fullKey] = subValue;
      }];
    } else {
      pairs[currentKey] = value;
    }
  }];
  
  return [pairs copy];
}

- (NSString *)pkc_queryStringByEscapingValues:(BOOL)escapeValues {
  NSMutableArray *pairs = [NSMutableArray new];
  
  NSDictionary *escapedPairs = escapeValues ? [self pkc_escapedQueryParametersPairs] : [self pkc_queryParametersPairs];
  [escapedPairs enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
    NSString *pair = [NSString stringWithFormat:@"%@=%@", key, value];
    [pairs addObject:pair];
  }];
  
  return [pairs componentsJoinedByString:@"&"];
}

@end
