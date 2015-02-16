//
//  PKCReversibleBlockValueTransformerTests.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 14/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCReversibleBlockValueTransformer.h"

@interface PKCReversibleBlockValueTransformerTests : XCTestCase

@end

@implementation PKCReversibleBlockValueTransformerTests

- (void)testTransformationWithReversibleBlock {
  PKCReversibleBlockValueTransformer *transformer = [PKCReversibleBlockValueTransformer transformerWithBlock:^id(NSNumber *num) {
    return @([num integerValue] * [num integerValue]);
  } reverseBlock:^id(NSNumber *num) {
    return @(sqrt([num integerValue]));
  }];
  
  expect([transformer reverseTransformedValue:[transformer transformedValue:@3]]).to.equal(@3);
}

@end
