//
//  NSDictionary+PKCAdditions.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 11/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSDictionary+PKCAdditions.h"

@implementation NSDictionary (PKCAdditions)

- (id)pkc_nonNullObjectForKey:(id)key {
  id value = self[key];
  if (value == [NSNull null]) {
    value = nil;
  }
  
  return value;
}

@end
