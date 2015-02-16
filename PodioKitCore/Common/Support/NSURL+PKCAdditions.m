//
//  NSURL+PKCAdditions.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 09/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSURL+PKCAdditions.h"
#import "NSString+PKCAdditions.h"
#import "NSDictionary+PKCQueryParameters.h"

@implementation NSURL (PKCAdditions)

- (NSURL *)pkc_URLByAppendingQueryParameters:(NSDictionary *)parameters {
  if ([parameters count] == 0) return self;
  
  NSMutableString *query = [NSMutableString stringWithString:self.absoluteString];
  
  if (![query pkc_containsString:@"?"]) {
    [query appendString:@"?"];
  } else {
    [query appendString:@"&"];
  }
  
  [query appendString:[parameters pkc_escapedQueryString]];
  
  return [NSURL URLWithString:[query copy]];
}

@end
