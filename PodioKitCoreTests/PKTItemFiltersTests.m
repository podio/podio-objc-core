//
//  PKTItemFiltersTests.m
//  PodioKitCore
//
//  Created by Sebastian Rehnby on 26/04/15.
//  Copyright (c) 2015 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKTItemFilters.h"

@interface PKTItemFiltersTests : XCTestCase

@end

@implementation PKTItemFiltersTests

- (void)testEmptyFilters {
  PKTItemFilters *filters = [PKTItemFilters new];
  expect([filters filtersDictionary]).to.equal(@{});
}

- (void)testOneFilters {
  PKTItemFilters *filters = [[PKTItemFilters new] withValue:@"Some text" forKey:@"category-field"];
  expect([filters filtersDictionary]).to.equal(@{@"category-field": @[@"Some text"]});
}

- (void)testMultipleFilters {
  PKTItemFilters *filters = [[[PKTItemFilters new]
    withValue:@"Some text" forKey:@"category-field"]
    withValues:@[@1, @2, @3] forKey:@"ref-field"];
  
  expect([filters filtersDictionary]).to.equal(@{@"category-field": @[@"Some text"],
                                                 @"ref-field": @[@1, @2, @3]});
}

@end
