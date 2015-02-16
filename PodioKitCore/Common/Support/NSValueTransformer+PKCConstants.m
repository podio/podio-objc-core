//
//  NSValueTransformer+PKCConstants.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 11/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSValueTransformer+PKCConstants.h"
#import "NSValueTransformer+PKCTransformers.h"

@implementation NSValueTransformer (PKCConstants)

+ (PKCReferenceType)pkc_referenceTypeFromString:(NSString *)string {
  id referenceTypeValue = [[NSValueTransformer pkc_referenceTypeTransformer] transformedValue:string];

  PKCReferenceType referenceType = PKCReferenceTypeUnknown;
  if ([referenceTypeValue isKindOfClass:[NSNumber class]]) {
    referenceType = [referenceTypeValue unsignedIntegerValue];
  }

  return referenceType;
}

+ (NSString *)pkc_stringFromReferenceType:(PKCReferenceType)referenceType {
  return [[NSValueTransformer pkc_referenceTypeTransformer] reverseTransformedValue:@(referenceType)];
}

@end
