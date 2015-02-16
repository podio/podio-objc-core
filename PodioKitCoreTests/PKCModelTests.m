//
//  PKCModelTests.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 23/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCTestModel.h"
#import "PKCNestedTestModel.h"

@interface PKCModelTests : XCTestCase

@end

@implementation PKCModelTests

- (void)testInitWithDictionary {
  PKCTestModel *obj = [self dummyTestModel];
  
  expect(obj.objectID).to.equal(12);
  expect(obj.firstValue).to.equal(@"some text 1");
  expect(obj.secondValue).to.equal(@"some text 2");
  
  expect(obj.nestedObjects).to.beKindOf([NSArray class]);
  expect(obj.nestedObjects).to.haveCountOf(2);
  expect(obj.nestedObjects[0]).to.beInstanceOf([PKCNestedTestModel class]);
  expect(obj.nestedObjects[1]).to.beInstanceOf([PKCNestedTestModel class]);
  
  expect(obj.nestedObject).to.beInstanceOf([PKCNestedTestModel class]);
  expect(obj.nestedObject.objectID).to.equal(125);
}

- (void)testCopying {
  PKCTestModel *obj = [self dummyTestModel];
  PKCTestModel *copyObj = [obj copy];
  expect(copyObj.objectID).to.equal(obj.objectID);
  expect(copyObj.firstValue).to.equal(obj.firstValue);
  expect(copyObj.secondValue).to.equal(obj.secondValue);
}

#pragma mark - Helpers

- (PKCTestModel *)dummyTestModel {
  NSDictionary *dictionary = @{
                               @"object_id": @12,
                               @"first_value": @"some text 1",
                               @"second_value": @"some text 2",
                               @"nested_objects":
                                 @[
                                   @{
                                     @"object_id": @123,
                                     @"first_value": @"some nested text 2",
                                     },
                                   @{
                                     @"object_id": @124,
                                     @"first_value": @"some nested text 2",
                                     }
                                   ],
                               @"nested_object":
                                 @{
                                   @"object_id": @125,
                                   @"first_value": @"some nested text 3",
                                   }
                               };
  
  return [[PKCTestModel alloc] initWithDictionary:dictionary];
}

@end
