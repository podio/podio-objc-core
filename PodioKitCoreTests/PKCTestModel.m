//
//  PKCTestModel.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 15/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCTestModel.h"
#import "PKCNestedTestModel.h"
#import "NSValueTransformer+PKCTransformers.h"

@implementation PKCTestModel

#pragma mark - PKCModel

+ (NSDictionary *)dictionaryKeyPathsForPropertyNames {
  return @{
    @"objectID": @"object_id",
    @"firstValue": @"first_value",
    @"secondValue": @"second_value",
    @"nestedObjects": @"nested_objects",
    @"nestedObject": @"nested_object",
  };
}

+ (NSValueTransformer *)nestedObjectsValueTransformer {
  return [NSValueTransformer pkc_transformerWithModelClass:[PKCNestedTestModel class]];
}

+ (NSValueTransformer *)nestedObjectValueTransformer {
  return [NSValueTransformer pkc_transformerWithModelClass:[PKCNestedTestModel class]];
}

@end
