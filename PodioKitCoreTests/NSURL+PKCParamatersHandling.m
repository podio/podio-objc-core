//
//  NSURL+PKCParamatersHandling.m
//  PodioKit
//
//  Created by Romain Briche on 22/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSURL+PKCParamatersHandling.h"
#import "NSString+PKCURL.h"

@implementation NSURL (PKCParamatersHandling)

- (NSString *)pkc_valueForQueryParameter:(NSString *)parameter {
  return [self pkc_queryParameters][parameter];
}

- (NSDictionary *)pkc_queryParameters {
  NSMutableDictionary *params = [NSMutableDictionary new];

  NSArray *chunks = [[self query] componentsSeparatedByString:@"&"];
  for (id obj in chunks) {
    NSArray *parts = [obj componentsSeparatedByString:@"="];

    if ([parts count] == 2) {
      NSString *name = parts[0];
      NSString *value = parts[1];
      params[name] = [value pkc_unescapedURLString];
    }
  }

  return [params copy];
}

@end
