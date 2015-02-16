//
//  PKCResponseTests.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 15/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCResponse.h"

@interface PKCResponseTests : XCTestCase

@end

@implementation PKCResponseTests

- (void)testInit {
  NSDictionary *body = @{@"key" : @"value"};
  PKCResponse *response = [[PKCResponse alloc] initWithStatusCode:200 body:body];
  expect(response.statusCode).to.equal(200);
  expect(response.body).to.equal(body);
}

@end
