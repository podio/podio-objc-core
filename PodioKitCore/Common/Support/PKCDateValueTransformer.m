//
//  PKCDateValueTransformer.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 02/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCDateValueTransformer.h"
#import "NSDate+PKCAdditions.h"
#import "PKCMacros.h"

@implementation PKCDateValueTransformer

- (instancetype)init {
  PKC_WEAK_SELF weakSelf = self;
  
  return [super initWithBlock:^id(NSString *dateString) {
    NSDate *date = [NSDate pkc_dateFromUTCDateTimeString:dateString];
    if (!date) {
      // Failed to parse time component, try date only
      date = [NSDate pkc_dateFromUTCDateString:dateString];
    }
    
    return date;
  } reverseBlock:^id(NSDate *date) {
    PKC_STRONG(weakSelf) strongSelf = weakSelf;
    
    NSString *dateString = nil;
    
    if (strongSelf.ignoresTimeComponent) {
      dateString = [date pkc_UTCDateString];
    } else {
      dateString = [date pkc_UTCDateTimeString];
    }
    
    return dateString;
  }];
}

@end
