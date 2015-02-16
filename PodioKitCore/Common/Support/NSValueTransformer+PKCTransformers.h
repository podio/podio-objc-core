//
//  NSValueTransformer+PKCTransformers.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 15/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKCBlockValueTransformer.h"
#import "PKCReversibleBlockValueTransformer.h"
#import "PKCModelValueTransformer.h"
#import "PKCURLValueTransformer.h"
#import "PKCReferenceTypeValueTransformer.h"
#import "PKCAppFieldTypeValueTransformer.h"
#import "PKCDateValueTransformer.h"

@interface NSValueTransformer (PKCTransformers)

+ (NSValueTransformer *)pkc_transformerWithBlock:(PKCValueTransformationBlock)block;
+ (NSValueTransformer *)pkc_transformerWithBlock:(PKCValueTransformationBlock)block reverseBlock:(PKCValueTransformationBlock)reverseBlock;
+ (NSValueTransformer *)pkc_transformerWithModelClass:(Class)modelClass;

+ (NSValueTransformer *)pkc_transformerWithDictionary:(NSDictionary *)dictionary;
+ (NSValueTransformer *)pkc_URLTransformer;
+ (NSValueTransformer *)pkc_dateValueTransformer;
+ (NSValueTransformer *)pkc_referenceTypeTransformer;
+ (NSValueTransformer *)pkc_appFieldTypeTransformer;
+ (NSValueTransformer *)pkc_numberValueTransformer;

@end
