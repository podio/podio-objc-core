//
//  PKCModelValueTransformerTests.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 15/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCModelValueTransformer.h"
#import "PKCTestModel.h"

@interface PKCModelValueTransformerTests : XCTestCase

@end

@implementation PKCModelValueTransformerTests

- (void)testForwardTransformationOfSingleObject {
  PKCModelValueTransformer *transformer = [PKCModelValueTransformer transformerWithModelClass:[PKCTestModel class]];
  
  PKCTestModel *obj = [transformer transformedValue:@{}];
  
  expect(obj).to.beInstanceOf([PKCTestModel class]);
}

- (void)testForwardTransformationOfArrayOfObjects {
  PKCModelValueTransformer *transformer = [PKCModelValueTransformer transformerWithModelClass:[PKCTestModel class]];

  NSArray *objs = [transformer transformedValue:@[@{}, @{}, @{}]];
  
  expect(objs).to.beKindOf([NSArray class]);
  expect(objs).to.haveCountOf(3);
  expect(objs[0]).to.beInstanceOf([PKCTestModel class]);
  expect(objs[1]).to.beInstanceOf([PKCTestModel class]);
  expect(objs[2]).to.beInstanceOf([PKCTestModel class]);
}

@end
