//
//  NSArray+PKCAdditions.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 01/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSArray+PKCAdditions.h"

@implementation NSArray (PKCAdditions)

- (instancetype)pkc_mappedArrayWithBlock:(id (^)(id obj))block {
  NSParameterAssert(block);
  
  NSMutableArray *mutArray = [[NSMutableArray alloc] initWithCapacity:[self count]];
  for (id object in self) {
    id mappedObject = block(object);
    if (mappedObject) {
      [mutArray addObject:mappedObject];
    }
  }
  
  return [mutArray copy];
}

- (instancetype)pkc_filteredArrayWithBlock:(BOOL (^)(id obj))block {
  NSParameterAssert(block);
  
  return [self pkc_mappedArrayWithBlock:^id(id obj) {
    return block(obj) ? obj : nil;
  }];
}

- (id)pkc_reducedValueWithBlock:(id (^)(id reduced, id obj))block {
  NSParameterAssert(block);
  
  id result = [self firstObject];
  
  for (NSUInteger i = 1; i < [self count]; ++i) {
    result = block(result, self[i]);
  }
  
  return result;
}

- (id)pkc_firstObjectPassingTest:(BOOL (^)(id obj))block {
  NSParameterAssert(block);
  
  __block id object = nil;
  [self enumerateObjectsUsingBlock:^(id currentObject, NSUInteger idx, BOOL *stop) {
    if (block(currentObject)) {
      object = currentObject;
      *stop = YES;
    }
  }];
  
  return object;
}

+ (instancetype)pkc_arrayFromRange:(NSRange)range {
  NSUInteger min = range.location;
  NSUInteger max = range.location + range.length;
  
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:range.length];
  for (NSUInteger i = min; i < max; ++i) {
    [array addObject:@(i)];
  }
  
  return [array copy];
}

@end
