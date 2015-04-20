//
//  PKCRequestSerializerTests.m
//  PodioKit
//
//  Created by Romain Briche on 29/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCRequestSerializer.h"
#import "PKCRequest.h"
#import "NSURL+PKCParamatersHandling.h"

@interface PKCRequestSerializerTests : XCTestCase

@property (nonatomic, strong) PKCRequestSerializer *testSerializer;
@property (nonatomic, copy) NSURL *baseURL;

@end

@implementation PKCRequestSerializerTests

- (void)setUp {
  [super setUp];
  self.testSerializer = [PKCRequestSerializer new];
  self.baseURL = [[NSURL alloc] initWithString:@"https://api.podio.com"];
}

- (void)tearDown {
  self.testSerializer = nil;
  [super tearDown];
}

#pragma mark - Tests

- (void)testSetCustomHeader {
  [self.testSerializer setValue:@"Header value" forHTTPHeader:@"X-Test-Header"];
  expect([self.testSerializer valueForHTTPHeader:@"X-Test-Header"]).to.equal(@"Header value");
}

- (void)testSetAuthorizationHeaderWithAPICredentials {
  expect([self.testSerializer valueForHTTPHeader:PKCRequestSerializerHTTPHeaderKeyAuthorization]).to.beNil;
  
  [self.testSerializer setAuthorizationHeaderWithAPIKey:@"my-key" secret:@"my-secret"];
  
  expect([self.testSerializer valueForHTTPHeader:PKCRequestSerializerHTTPHeaderKeyAuthorization]).to.contain(@"Basic ");
  expect([self.testSerializer valueForHTTPHeader:PKCRequestSerializerHTTPHeaderKeyAuthorization]).notTo.contain(@"my-key");
  expect([self.testSerializer valueForHTTPHeader:PKCRequestSerializerHTTPHeaderKeyAuthorization]).notTo.contain(@"my-secret");
  expect([[self.testSerializer valueForHTTPHeader:PKCRequestSerializerHTTPHeaderKeyAuthorization] length]).to.beGreaterThan([@"Basic " length]);
}

- (void)testSetAuthorizationHeaderFieldWithOAuth2AccessToken {
  NSString *accessToken = @"some-access-token";
  
  PKCRequestSerializer *requestSerializer = [PKCRequestSerializer new];
  [requestSerializer setAuthorizationHeaderWithOAuth2AccessToken:accessToken];
  
  NSString *expectedHTTPHeader = [NSString stringWithFormat:@"OAuth2 %@", accessToken];
  expect([requestSerializer valueForHTTPHeader:PKCRequestSerializerHTTPHeaderKeyAuthorization]).to.equal(expectedHTTPHeader);
}

- (void)testURLRequestForGETRequest {
  PKCRequest *request = [PKCRequest GETRequestWithPath:@"/some/path" parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];

  NSURLRequest *urlRequest = [self.testSerializer URLRequestForRequest:request relativeToURL:self.baseURL];
  expect(urlRequest.URL.path).to.equal(request.path);
  expect(urlRequest.HTTPMethod).to.equal(@"GET");
  expect([[urlRequest URL] pkc_queryParameters]).to.pkc_beSupersetOf(request.parameters);
  expect([[urlRequest allHTTPHeaderFields][@"X-Podio-Request-Id"] length]).to.beGreaterThan(0);
}

- (void)testURLRequestForPOSTRequest {
  PKCRequest *request = [PKCRequest POSTRequestWithPath:@"/some/path" parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];

  NSURLRequest *urlRequest = [self.testSerializer URLRequestForRequest:request relativeToURL:self.baseURL];
  expect(urlRequest.URL.path).to.equal(request.path);
  expect(urlRequest.HTTPMethod).to.equal(@"POST");

  NSError *error = nil;
  id bodyParameters = [NSJSONSerialization JSONObjectWithData:[urlRequest HTTPBody] options:0 error:&error];
  bodyParameters = [NSDictionary dictionaryWithDictionary:bodyParameters];
  expect(bodyParameters).to.pkc_beSupersetOf(request.parameters);
  expect([[urlRequest allHTTPHeaderFields][@"X-Podio-Request-Id"] length]).to.beGreaterThan(0);
  expect([urlRequest allHTTPHeaderFields][@"Content-Type"]).to.equal(@"application/json; charset=utf-8");
}

- (void)testURLRequestForPUTRequest {
  PKCRequest *request = [PKCRequest PUTRequestWithPath:@"/some/path" parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];

  NSURLRequest *urlRequest = [self.testSerializer URLRequestForRequest:request relativeToURL:self.baseURL];
  expect(urlRequest.URL.path).to.equal(request.path);
  expect(urlRequest.HTTPMethod).to.equal(@"PUT");

  NSError *error = nil;
  NSDictionary *bodyParameters = [[NSJSONSerialization JSONObjectWithData:[urlRequest HTTPBody] options:0 error:&error] copy];
  bodyParameters = [NSDictionary dictionaryWithDictionary:bodyParameters];
  expect(bodyParameters).to.pkc_beSupersetOf(request.parameters);
  expect([[urlRequest allHTTPHeaderFields][@"X-Podio-Request-Id"] length]).to.beGreaterThan(0);
  expect([urlRequest allHTTPHeaderFields][@"Content-Type"]).to.equal(@"application/json; charset=utf-8");
}

- (void)testURLRequestForDELETERequest {
  PKCRequest *request = [PKCRequest DELETERequestWithPath:@"/some/path" parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];

  NSURLRequest *urlRequest = [self.testSerializer URLRequestForRequest:request relativeToURL:self.baseURL];
  expect(urlRequest.URL.path).to.equal(request.path);
  expect(urlRequest.HTTPMethod).to.equal(@"DELETE");
  expect([[urlRequest URL] pkc_queryParameters]).to.pkc_beSupersetOf(request.parameters);
  expect([[urlRequest allHTTPHeaderFields][@"X-Podio-Request-Id"] length]).to.beGreaterThan(0);
}

- (void)testFormURLEncodedRequest {
  PKCRequest *request = [PKCRequest POSTRequestWithPath:@"/some/path" parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];
  request.contentType = PKCRequestContentTypeFormURLEncoded;
  
  NSURLRequest *urlRequest = [self.testSerializer URLRequestForRequest:request relativeToURL:self.baseURL];
  NSString *bodyString = [[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding];
  expect(bodyString).to.contain(@"param1=someValue");
  expect(bodyString).to.contain(@"param2=someOtherValue");
}

- (void)testMultipartRequest {
  PKCRequest *request = [PKCRequest POSTRequestWithPath:@"/some/path" parameters:@{@"param1" : @"someValue"}];
  request.contentType = PKCRequestContentTypeMultipart;
  request.fileData = [PKCRequestFileData fileDataWithData:[NSData data] name:@"name" fileName:@"image.jpg"];
  
  PKCMultipartFormData *multipartData = [self.testSerializer multipartFormDataFromRequest:request];
  NSURLRequest *urlRequest = [self.testSerializer URLRequestForRequest:request multipartData:multipartData relativeToURL:self.baseURL];
  expect(urlRequest.allHTTPHeaderFields[@"Content-Type"]).to.contain(@"multipart/form-data");
  expect(urlRequest.allHTTPHeaderFields[@"Content-Length"]).toNot.beNil();
}

- (void)testURLRequestForAbsoluteURL {
  NSURL *url = [NSURL URLWithString:@"https://some.other.domain.com/some/path"];
  PKCRequest *request = [PKCRequest GETRequestWithURL:url parameters:@{@"param1": @"someValue", @"param2": @"someOtherValue"}];
  
  NSURLRequest *urlRequest = [self.testSerializer URLRequestForRequest:request relativeToURL:self.baseURL];
  expect(urlRequest.URL.scheme).to.equal(@"https");
  expect(urlRequest.URL.host).to.equal(@"some.other.domain.com");
  expect(urlRequest.URL.path).to.equal(@"/some/path");
  expect(urlRequest.HTTPMethod).to.equal(@"GET");
  expect([urlRequest.URL pkc_queryParameters]).to.pkc_beSupersetOf(request.parameters);
  expect([urlRequest.allHTTPHeaderFields[@"X-Podio-Request-Id"] length]).to.beGreaterThan(0);
}

- (void)testSetUserAgentHeader {
  NSString *userAgent = @"Some user agent";
  [self.testSerializer setUserAgentHeader:userAgent];
  expect([self.testSerializer valueForHTTPHeader:PKCRequestSerializerHTTPHeaderKeyUserAgent]).to.equal(userAgent);
}

@end
