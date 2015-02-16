//
//  PKCResponseSerializer.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 09/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCResponseSerializer.h"
#import "NSString+PKCAdditions.h"

@implementation PKCResponseSerializer

- (id)responseObjectForURLResponse:(NSURLResponse *)response data:(NSData *)data {
  if (![response isKindOfClass:[NSHTTPURLResponse class]]) return nil;
  
  id object = nil;
  NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
  if ([HTTPResponse.allHeaderFields[@"Content-Type"] pkc_containsString:@"application/json"]) {
    object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  } else {
    object = data;
  }
  
  return object;
}

@end
