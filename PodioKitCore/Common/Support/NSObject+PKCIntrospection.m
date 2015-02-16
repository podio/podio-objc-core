//
//  NSObject+PKCIntrospection.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 14/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+PKCIntrospection.h"

@implementation NSObject (PKCIntrospection)

+ (id)pkc_valueByPerformingSelectorWithName:(NSString *)selectorName {
  return [self pkc_valueByPerformingSelectorWithName:selectorName withObject:nil];
}

+ (id)pkc_valueByPerformingSelectorWithName:(NSString *)selectorName withObject:(id)object {
  id value = nil;
  
  SEL selector = NSSelectorFromString(selectorName);
  if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    value = [self performSelector:selector withObject:object];
#pragma clang diagnostic pop
  }
  
  return value;
}

@end
