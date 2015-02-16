//
//  NSNumber(PKCAdditions) 
//  PodioKit
//
//  Created by Sebastian Rehnby on 18/05/14
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//


#import "NSNumber+PKCAdditions.h"
#import "NSNumberFormatter+PKCAdditions.h"

static NSNumberFormatter *sNumberFormatter = nil;

@implementation NSNumber (PKCAdditions)

+ (NSNumber *)pkc_numberFromUSNumberString:(NSString *)numberString {
  return [[self pkc_USNumberFormatter] numberFromString:numberString];
}

- (NSString *)pkc_USNumberString {
  return [[[self class] pkc_USNumberFormatter] stringFromNumber:self];
}

+ (NSNumberFormatter *)pkc_USNumberFormatter {
  if (!sNumberFormatter) {
    sNumberFormatter = [NSNumberFormatter pkc_USNumberFormatter];
  }

  return sNumberFormatter;
}

@end