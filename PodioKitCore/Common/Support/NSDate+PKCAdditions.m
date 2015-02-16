//
//  NSDate+PKCAdditions.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 08/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSDate+PKCAdditions.h"
#import "NSDateFormatter+PKCAdditions.h"

static NSDateFormatter *sUTCDateFormatter = nil;
static NSDateFormatter *sUTCDateTimeFormatter = nil;

@implementation NSDate (PKCAdditions)

#pragma mark - Public

+ (NSDate *)pkc_dateFromUTCDateString:(NSString *)dateString {
  return [[self UTCDateFormatter] dateFromString:dateString];
}

+ (NSDate *)pkc_dateFromUTCDateTimeString:(NSString *)dateTimeString {
  return [[self UTCDateTimeFormatter] dateFromString:dateTimeString];
}

- (NSString *)pkc_UTCDateString {
  return [[[self class] UTCDateFormatter] stringFromDate:self];
}

- (NSString *)pkc_UTCDateTimeString {
  return [[[self class] UTCDateTimeFormatter] stringFromDate:self];
}

#pragma mark - Private

+ (NSDateFormatter *)UTCDateFormatter {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sUTCDateFormatter = [NSDateFormatter pkc_UTCDateFormatter];
  });
  
  return sUTCDateFormatter;
}

+ (NSDateFormatter *)UTCDateTimeFormatter {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sUTCDateTimeFormatter = [NSDateFormatter pkc_UTCDateTimeFormatter];
  });
  
  return sUTCDateTimeFormatter;
}

@end
