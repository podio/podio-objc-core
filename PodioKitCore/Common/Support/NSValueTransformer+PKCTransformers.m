//
//  NSValueTransformer+PKCTransformers.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 15/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSValueTransformer+PKCTransformers.h"
#import "PKCConstants.h"
#import "PKCNumberValueTransformer.h"

@implementation NSValueTransformer (PKCTransformers)

+ (NSValueTransformer *)pkc_transformerWithBlock:(PKCValueTransformationBlock)block {
  return [PKCBlockValueTransformer transformerWithBlock:block];
}

+ (NSValueTransformer *)pkc_transformerWithBlock:(PKCValueTransformationBlock)block reverseBlock:(PKCValueTransformationBlock)reverseBlock {
  return [PKCReversibleBlockValueTransformer transformerWithBlock:block reverseBlock:reverseBlock];
}

+ (NSValueTransformer *)pkc_transformerWithModelClass:(Class)modelClass {
  return [PKCModelValueTransformer transformerWithModelClass:modelClass];
}

+ (NSValueTransformer *)pkc_transformerWithDictionary:(NSDictionary *)dictionary {
  return [PKCDictionaryMappingValueTransformer transformerWithDictionary:dictionary];
}

+ (NSValueTransformer *)pkc_URLTransformer {
  return [PKCURLValueTransformer new];
}

+ (NSValueTransformer *)pkc_dateValueTransformer {
  return [PKCDateValueTransformer new];
}

+ (NSValueTransformer *)pkc_referenceTypeTransformer {
  return [PKCReferenceTypeValueTransformer new];
}

+ (NSValueTransformer *)pkc_appFieldTypeTransformer {
  return [PKCAppFieldTypeValueTransformer new];
}

+ (NSValueTransformer *)pkc_numberValueTransformer {
  return [PKCNumberValueTransformer new];
}
@end
