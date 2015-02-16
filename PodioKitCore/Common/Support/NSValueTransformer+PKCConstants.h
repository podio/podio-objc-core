//
//  NSValueTransformer+PKCConstants.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 11/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKCConstants.h"

@interface NSValueTransformer (PKCConstants)

+ (PKCReferenceType)pkc_referenceTypeFromString:(NSString *)string;
+ (NSString *)pkc_stringFromReferenceType:(PKCReferenceType)referenceType;

@end
