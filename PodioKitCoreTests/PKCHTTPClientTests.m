//
//  PKCClientTests.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 16/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCHTTPClient.h"
#import "PKCRequest.h"
#import "PKCResponse.h"
#import "PKCHTTPStubs.h"
#import "NSError+PKCErrors.h"

@interface PKCHTTPClientTests : XCTestCase

@property (nonatomic, strong) PKCHTTPClient *testClient;

@end

@implementation PKCHTTPClientTests

- (void)setUp {
  [super setUp];
  self.testClient = [PKCHTTPClient new];
}

- (void)tearDown {
  self.testClient = nil;
  [Expecta setAsynchronousTestTimeout:1];
  [super tearDown];
}

#pragma mark - Tests

- (void)testInit {
  PKCHTTPClient *client = [PKCHTTPClient new];
  expect([client.baseURL absoluteString]).to.equal(@"https://api.podio.com");
}

- (void)testPerformSuccessfulRequest {
  NSString *path = @"/user/status";
  PKCRequest *request = [PKCRequest GETRequestWithPath:path parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];

  [PKCHTTPStubs stubResponseForPath:path statusCode:200];

  __block BOOL completed = NO;
  NSURLSessionTask *task = [self.testClient taskForRequest:request progress:nil completion:^(PKCResponse *result, NSError *error) {
    if (!error) {
      completed = YES;
    }
  }];
  
  [task resume];

  expect(task).notTo.beNil();
  expect(completed).will.beTruthy();
}

- (void)testPerformUnsuccessfulRequest {
  NSString *path = @"/user/status";
  PKCRequest *request = [PKCRequest GETRequestWithPath:path parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];

  [PKCHTTPStubs stubResponseForPath:path statusCode:500];

  __block BOOL errorOccured = NO;
  NSURLSessionTask *task = [self.testClient taskForRequest:request progress:nil completion:^(PKCResponse *result, NSError *error) {
    if (error) {
      errorOccured = YES;
    }
  }];
  
  [task resume];

  expect(errorOccured).will.beTruthy();
}

- (void)testTimeoutRequest {
  NSString *path = @"/user/status";
  PKCRequest *request = [PKCRequest GETRequestWithPath:path parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];

  [Expecta setAsynchronousTestTimeout:5];
  [PKCHTTPStubs stubResponseForPath:path requestTime:2 responseTime:0];

  __block BOOL completed = NO;
  NSURLSessionTask *task = [self.testClient taskForRequest:request progress:nil completion:^(PKCResponse *result, NSError *error) {
    completed = YES;
  }];
  
  [task resume];

  expect(completed).will.beFalsy();
}

- (void)testCancelRequest {
  NSString *path = @"/user/status";
  PKCRequest *request = [PKCRequest GETRequestWithPath:path parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];

  [Expecta setAsynchronousTestTimeout:5];
  [PKCHTTPStubs stubResponseForPath:path requestTime:5 responseTime:0];

  __block BOOL cancelled = NO;
  NSURLSessionTask *task = [self.testClient taskForRequest:request progress:nil completion:^(PKCResponse *result, NSError *error) {
    if (error.code == NSURLErrorCancelled) {
      cancelled = YES;
    }
  }];

  [task resume];
  
  expect(task).notTo.beNil();

  [task cancel];

  expect(cancelled).will.beTruthy();
}

- (void)testSuspendRequest {
  NSString *path = @"/user/status";
  PKCRequest *request = [PKCRequest GETRequestWithPath:path parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];

  [Expecta setAsynchronousTestTimeout:5];
  [PKCHTTPStubs stubResponseForPath:path requestTime:5 responseTime:0];

  __block BOOL completed = NO;
  NSURLSessionTask *task = [self.testClient taskForRequest:request progress:nil completion:^(PKCResponse *result, NSError *error) {
    completed = YES;
  }];
  
  [task resume];
  expect(task).notTo.beNil();

  [task suspend];
  expect(completed).will.beFalsy();
}

- (void)testResumeRequest {
  NSString *path = @"/user/status";
  PKCRequest *request = [PKCRequest GETRequestWithPath:path parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];

  [Expecta setAsynchronousTestTimeout:5];
  [PKCHTTPStubs stubResponseForPath:path requestTime:2 responseTime:0];

  __block BOOL completed = NO;
  NSURLSessionTask *task = [self.testClient taskForRequest:request progress:nil completion:^(PKCResponse *result, NSError *error) {
    completed = YES;
  }];

  [task resume];
  expect(task).notTo.beNil();

  [task suspend];
  expect(completed).will.beFalsy();
  
  wait(1);
  
  [task resume];
  expect(completed).will.beTruthy();
}

- (void)testReturnsServerError {
  NSString *path = @"/some/path";
  PKCRequest *request = [PKCRequest GETRequestWithPath:path parameters:nil];
  
  [PKCHTTPStubs stubResponseForPath:path block:^(PKCHTTPStubber *stubber) {
    stubber.statusCode = 400;
    stubber.responseObject = @{
      @"error" : @"invalid_grant",
      @"error_description" : @"The username is not valid",
      @"error_detail" : @"user.invalid.username",
      @"error_parameters" : @{},
      @"error_propagate" : @1
      };
  }];
  
  __block BOOL completed = NO;
  __block NSError *serverError = nil;
  NSURLSessionTask *task = [self.testClient taskForRequest:request progress:nil completion:^(PKCResponse *result, NSError *error) {
    completed = YES;
    serverError = error;
  }];
  
  [task resume];
  expect(completed).will.beTruthy();
  expect(serverError.domain).to.equal(PodioServerErrorDomain);
  expect(serverError.code).to.equal(400);
}

- (void)testDownloadRequestIsDownloadTask {
  PKCRequest *request = [PKCRequest GETRequestWithURL:[NSURL URLWithString:@"https://files.podio.com/111111"] parameters:nil];
  request.fileData = [PKCRequestFileData fileDataWithFilePath:@"/tmp/file.pdf" name:nil fileName:nil];
  
  id task = [self.testClient taskForRequest:request progress:nil completion:nil];
  expect(task).to.beKindOf([NSURLSessionDownloadTask class]);
}

- (void)testSetUserAgent {
  NSString *userAgent = @"Some user agent";
  self.testClient.userAgent = userAgent;
  expect([self.testClient.requestSerializer valueForHTTPHeader:PKCRequestSerializerHTTPHeaderKeyUserAgent]).to.equal(userAgent);
  expect(self.testClient.userAgent).to.equal(userAgent);
  
  userAgent = @"Some other user agent";
  [self.testClient.requestSerializer setUserAgentHeader:userAgent];
  expect(self.testClient.userAgent).to.equal(userAgent);
}

@end
