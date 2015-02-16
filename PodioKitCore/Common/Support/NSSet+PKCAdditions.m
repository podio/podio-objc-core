//
//  NSSet+PKCAdditions.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 29/10/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSSet+PKCAdditions.h"

@implementation NSSet (PKCAdditions)

- (instancetype)pkc_mappedSetWithBlock:(id (^)(id obj))block {
  NSParameterAssert(block);
  
  NSMutableSet *mutSet = [[NSMutableSet alloc] initWithCapacity:[self count]];
  for (id object in self) {
    id mappedObject = block(object);
    if (mappedObject) {
      [mutSet addObject:mappedObject];
    }
  }
  
  return [mutSet copy];
}

- (instancetype)pkc_filteredSetWithBlock:(BOOL (^)(id obj))block {
  NSParameterAssert(block);
  
  return [self pkc_mappedSetWithBlock:^id(id obj) {
    return block(obj) ? obj : nil;
  }];
}

@end
