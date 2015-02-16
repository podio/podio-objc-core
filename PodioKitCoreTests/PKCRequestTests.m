//
//  PKCRequestTests.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 21/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCRequest.h"

@interface PKCRequestTests : XCTestCase

@end

@implementation PKCRequestTests

- (void)testGETRequest {
  NSString *path = @"/some/path";
  NSDictionary *params = @{@"param1": @"someValue", @"param2": @"someOtherValue"};
  PKCRequest *request = [PKCRequest GETRequestWithPath:path parameters:params];
  expect(request.method).to.equal(PKCRequestMethodGET);
  expect(request.path).to.equal(path);
  expect(request.parameters).to.equal(params);
}

- (void)testPOSTRequest {
  NSString *path = @"/some/path";
  NSDictionary *params = @{@"param1": @"someValue", @"param2": @"someOtherValue"};
  PKCRequest *request = [PKCRequest POSTRequestWithPath:path parameters:params];
  expect(request.method).to.equal(PKCRequestMethodPOST);
  expect(request.path).to.equal(path);
  expect(request.parameters).to.equal(params);
}

- (void)testPUTRequest {
  NSString *path = @"/some/path";
  NSDictionary *params = @{@"param1": @"someValue", @"param2": @"someOtherValue"};
  PKCRequest *request = [PKCRequest PUTRequestWithPath:path parameters:params];
  expect(request.method).to.equal(PKCRequestMethodPUT);
  expect(request.path).to.equal(path);
}

- (void)testDELETERequest {
  NSString *path = @"/some/path";
  NSDictionary *params = @{@"param1": @"someValue", @"param2": @"someOtherValue"};
  PKCRequest *request = [PKCRequest DELETERequestWithPath:path parameters:params];
  expect(request.method).to.equal(PKCRequestMethodDELETE);
  expect(request.path).to.equal(path);
  expect(request.parameters).to.equal(params);
}

@end
