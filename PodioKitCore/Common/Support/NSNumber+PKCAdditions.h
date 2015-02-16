//
//  NSNumber(PKCAdditions) 
//  PodioKit
//
//  Created by Sebastian Rehnby on 18/05/14
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSNumber (PKCAdditions)

+ (NSNumber *)pkc_numberFromUSNumberString:(NSString *)numberString;
- (NSString *)pkc_USNumberString;

@end