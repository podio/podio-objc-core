//
//  NSDate+PKCAdditions.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 08/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (PKCAdditions)

+ (NSDate *)pkc_dateFromUTCDateString:(NSString *)dateString;
+ (NSDate *)pkc_dateFromUTCDateTimeString:(NSString *)dateTimeString;

- (NSString *)pkc_UTCDateString;
- (NSString *)pkc_UTCDateTimeString;

@end
