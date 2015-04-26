//
//  PKTItemFilters.h
//  PodioKitCore
//
//  Created by Sebastian Rehnby on 26/04/15.
//  Copyright (c) 2015 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKTItemFilters : NSObject

/**
 *  Limits the filter by some permitted values of a given key.
 *
 *  @param values     The permitted values of the key.
 *  @param key        The filter key.
 *
 *  @return The filter.
 */
- (instancetype)withValues:(NSArray *)values forKey:(NSString *)key;

/**
 *  Limits the filter by a permitted value of a given key. Passing nil as the value will limit by the
 *  "not set" filter for this key.
 *
 *  @param value     The permitted value of the key.
 *  @param key       The filter key.
 *
 *  @return The filter.
 */
- (instancetype)withValue:(id)value forKey:(NSString *)key;

/**
 *  Generates a dictionary representing the values of this filter.
 *
 *  @return An NSDictionary containing the filter values as they should be passed to the API.
 */
- (NSDictionary *)filtersDictionary;

@end
