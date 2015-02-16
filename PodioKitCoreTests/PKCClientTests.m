//
//  PKCSessionManagerTests.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 27/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "PKCClient.h"
#import "PKCHTTPClient.h"
#import "PKCAuthenticationAPI.h"
#import "PKCUsersAPI.h"
#import "PKCOAuth2Token.h"
#import "PKCHTTPStubs.h"
#import "PKCClient+Test.h"
#import "NSString+PKCBase64.h"
#import "PKCAsyncTask.h"

@interface PKCClientTests : XCTestCase

@property (nonatomic, strong) PKCClient *testClient;

@end

@implementation PKCClientTests

- (void)setUp {
  [super setUp];
  self.testClient = [PKCClient new];
  [self.testClient setupWithAPIKey:@"my-api-key" secret:@"my-api-secret"];
  
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [request.URL.host isEqualToString:self.testClient.HTTPClient.baseURL.host];
  } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
    return [OHHTTPStubsResponse responseWithData:nil statusCode:200 headers:nil];
  }];
}

- (void)tearDown {
  self.testClient = nil;
  [super tearDown];
}

#pragma mark - Tests

- (void)testSharedInstance {
  expect([PKCClient defaultClient]).to.equal([PKCClient defaultClient]);
}

- (void)testNestedClients {
  expect([PKCClient currentClient]).to.equal([PKCClient defaultClient]);
  
  PKCClient *client1 = [PKCClient new];
  [client1 performBlock:^{
    expect([PKCClient currentClient]).to.equal(client1);
    
    PKCClient *client2 = [PKCClient new];
    [client2 performBlock:^{
      expect([PKCClient currentClient]).to.equal(client2);
    }];
    
    expect([PKCClient currentClient]).to.equal(client1);
  }];
  
  expect([PKCClient currentClient]).to.equal([PKCClient defaultClient]);
}

- (void)testInitWithClient {
  PKCHTTPClient *httpClient = [PKCHTTPClient new];
  PKCClient *client = [[PKCClient alloc] initWithHTTPClient:httpClient];
  expect(client.HTTPClient).to.equal(httpClient);
  expect(client.oauthToken).to.beNil();
  expect(client.isAuthenticated).to.beFalsy();
}

- (void)testSetupWithAPIKeyAndSecret {
  PKCClient *client = [PKCClient new];
  expect(client.apiKey).to.beNil();
  expect(client.apiSecret).to.beNil();
  
  [client setupWithAPIKey:@"my-key" secret:@"my-secret"];
  expect(client.apiKey).to.equal(@"my-key");
  expect(client.apiSecret).to.equal(@"my-secret");
}

- (void)testSetOAuthToken {
  PKCClient *client = [PKCClient new];
  
  PKCOAuth2Token *token = [self dummyAuthToken];
  client.oauthToken = token;
  
  expect(client.oauthToken).to.equal(token);
}


- (void)testSuccessfulRefreshTokenReplacesToken {
  PKCOAuth2Token *initialToken = [self dummyAuthToken];
  self.testClient.oauthToken = initialToken;
  
  NSDictionary *tokenDict = [self dummyAuthTokenDict];
  
  PKCRequest *request = [PKCAuthenticationAPI requestToRefreshToken:self.testClient.oauthToken.refreshToken];
  [PKCHTTPStubs stubResponseForPath:request.path responseObject:tokenDict];
  
  __block BOOL completed = NO;
  PKCAsyncTask *task = [[self.testClient refreshToken] onSuccess:^(id result) {
    completed = YES;
  }];
  
  expect(task).notTo.beNil();
//  expect(task.currentRequest.allHTTPHeaderFields[@"Authorization"]).equal([self basicAuthHeaderForTestClient]);

  expect(completed).will.beTruthy();
  expect(self.testClient.isAuthenticated).to.beTruthy();
  expect(self.testClient.oauthToken).notTo.equal(initialToken);
}

- (void)testTokenShouldBeNilAfterFailedRefreshDueToServerSideError {
  PKCOAuth2Token *initialToken = [self dummyAuthToken];
  self.testClient.oauthToken = initialToken;
  
  PKCRequest *request = [PKCAuthenticationAPI requestToRefreshToken:self.testClient.oauthToken.refreshToken];
  [PKCHTTPStubs stubResponseForPath:request.path statusCode:401];
  
  __block BOOL completed = NO;
  PKCAsyncTask *task = [[self.testClient refreshToken] onError:^(NSError *error) {
    completed = YES;
  }];
  
  expect(task).notTo.beNil();
  expect(completed).will.beTruthy();
  expect(self.testClient.oauthToken).to.beNil();
}

- (void)testTokenShouldBeSameAfterFailedRefreshDueToNoInternet {
  PKCOAuth2Token *initialToken = [self dummyAuthToken];
  self.testClient.oauthToken = initialToken;
  
  PKCRequest *request = [PKCAuthenticationAPI requestToRefreshToken:self.testClient.oauthToken.refreshToken];
  [PKCHTTPStubs stubNetworkDownForPath:request.path];
  
  __block BOOL completed = NO;
  PKCAsyncTask *task = [[self.testClient refreshToken] onError:^(NSError *error) {
    completed = YES;
  }];
  
  expect(task).notTo.beNil();
  expect(completed).will.beTruthy();
  expect(self.testClient.oauthToken).to.equal(initialToken);
}

- (void)testMultipleRequestsWithExpiredTokenShouldFinishAfterSuccessfulTokenRefresh {
  // Make sure the current token is expired
  PKCOAuth2Token *expiredToken = [self dummyAuthTokenWithExpirationSinceNow:-600]; // Expired 10 minutes ago
  self.testClient.oauthToken = expiredToken;
  
  // Return a refreshed token
  NSDictionary *refreshedTokenDict = [self dummyAuthTokenDictWithExpirationSinceNow:3600]; // Expires in 1h
  PKCRequest *refreshRequest = [PKCAuthenticationAPI requestToRefreshToken:self.testClient.oauthToken.refreshToken];
  [PKCHTTPStubs stubResponseForPath:refreshRequest.path responseObject:refreshedTokenDict];
  
  // Make a normal request that should finish after the refresh
  PKCRequest *request = [PKCUsersAPI requestForUserStatus];
  
  // Make 1st request
  [PKCHTTPStubs stubResponseForPath:request.path statusCode:200];
  
  __block BOOL completed1 = NO;
  __block BOOL isError1 = NO;
  [[self.testClient performRequest:request] onSuccess:^(id result) {
    completed1 = YES;
    isError1 = NO;
  } onError:^(NSError *error) {
    completed1 = YES;
    isError1 = YES;
  }];

  expect(completed1).will.beTruthy();
  expect(isError1).to.beFalsy();
  
  // Make 2nd request
  [PKCHTTPStubs stubResponseForPath:request.path statusCode:200];
  
  __block BOOL completed2 = NO;
  __block BOOL isError2 = NO;
  [[self.testClient performRequest:request] onSuccess:^(id result) {
    completed2 = YES;
    isError2 = NO;
  } onError:^(NSError *error) {
    completed2 = YES;
    isError2 = YES;
  }];
  
  expect(completed2).will.beTruthy();
  expect(isError2).to.beFalsy();
  
  expect(self.testClient.oauthToken).toNot.equal(expiredToken);
  expect([self.testClient.oauthToken willExpireWithinIntervalFromNow:10]).to.beFalsy();
}

- (void)testMultipleRequestsWithExpiredTokenShouldFailAfterRefreshFailed {
  // Make sure the current token is expired
  PKCOAuth2Token *expiredToken = [self dummyAuthTokenWithExpirationSinceNow:-600]; // Expired 10 minutes ago
  self.testClient.oauthToken = expiredToken;
  
  // Return a 401, failed to refresh token
  PKCRequest *refreshRequest = [PKCAuthenticationAPI requestToRefreshToken:self.testClient.oauthToken.refreshToken];
  [PKCHTTPStubs stubResponseForPath:refreshRequest.path statusCode:401];
  
  // Make a normal request that should fail after the failed refresh
  PKCRequest *request = [PKCUsersAPI requestForUserStatus];
  
  // Make 1st request
  [PKCHTTPStubs stubResponseForPath:request.path statusCode:200];
  
  __block BOOL completed1 = NO;
  __block BOOL isCancelError1 = NO;
  [[self.testClient performRequest:request] onSuccess:^(id result) {
    completed1 = YES;
    isCancelError1 = NO;
  } onError:^(NSError *error) {
    completed1 = YES;
    isCancelError1 = error.code == NSURLErrorCancelled;
  }];
  
  // Make 2nd request
  [PKCHTTPStubs stubResponseForPath:request.path statusCode:200];
  
  __block BOOL completed2 = NO;
  __block BOOL isCancelError2 = NO;
  [[self.testClient performRequest:request] onSuccess:^(id result) {
    completed2 = YES;
    isCancelError2 = NO;
  } onError:^(NSError *error) {
    completed2 = YES;
    isCancelError2 = error.code == NSURLErrorCancelled;
  }];
  
  expect(completed1).will.beTruthy();
  expect(isCancelError1).to.beTruthy();
  
  expect(completed2).will.beTruthy();
  expect(isCancelError2).to.beTruthy();
}

- (void)testClientShouldResetTokenIfReceiving401 {
  self.testClient.oauthToken = [self dummyAuthToken];

  // Make a normal request that should fail with the
  PKCRequest *request = [PKCUsersAPI requestForUserStatus];
  [PKCHTTPStubs stubResponseForPath:request.path statusCode:401];
  
  __block BOOL completed = NO;
  [[self.testClient performRequest:request] onComplete:^(id result, NSError *error) {
    completed = YES;
  }];
  
  expect(completed).will.beTruthy();
  expect(self.testClient.isAuthenticated).will.beFalsy();
}

- (void)testClientShouldHaveUpdatedAuthorizationHeaderAfterSuccessfulTokenRefresh {
  // Make sure the current token is expired
  PKCOAuth2Token *expiredToken = [self dummyAuthTokenWithExpirationSinceNow:-600]; // Expired 10 minutes ago
  self.testClient.oauthToken = expiredToken;
  
  // Return a refreshed token
  NSMutableDictionary *refreshedTokenDict = [[self dummyAuthTokenDictWithExpirationSinceNow:3600] mutableCopy]; // Expires in 1h
  refreshedTokenDict[@"access_token"] = @"new_access_token";
  
  PKCRequest *refreshRequest = [PKCAuthenticationAPI requestToRefreshToken:self.testClient.oauthToken.refreshToken];
  [PKCHTTPStubs stubResponseForPath:refreshRequest.path responseObject:refreshedTokenDict];
  
  // Make a normal request that should fail after the failed refresh
  PKCRequest *request = [PKCUsersAPI requestForUserStatus];
  
  // Make 1st request
  [PKCHTTPStubs stubResponseForPath:request.path statusCode:200];
  
  NSString *beforeHeader = self.testClient.HTTPClient.requestSerializer.additionalHTTPHeaders[@"Authorization"];
  
  __block BOOL completed = NO;
  [[self.testClient performRequest:request] onSuccess:^(id result) {
    completed = YES;
  }];
  
  expect(completed).will.beTruthy();
  
  NSString *afterHeader = self.testClient.HTTPClient.requestSerializer.additionalHTTPHeaders[@"Authorization"];
  expect(afterHeader).toNot.equal(beforeHeader);
}

- (void)testAuthenticationWithEmailAndPassword {
  NSDictionary *tokenDict = [self dummyAuthTokenDict];
  PKCRequest *authRequest = [PKCAuthenticationAPI requestForAuthenticationWithEmail:@"me@domain.com" password:@"p4$$w0rD"];
  [PKCHTTPStubs stubResponseForPath:authRequest.path responseObject:tokenDict];
  
  __block BOOL completed = NO;
  [[self.testClient authenticateAsUserWithEmail:@"me@domain.com" password:@"p4$$w0rD"] onSuccess:^(id result) {
    completed = YES;
  }];

  expect(self.testClient.HTTPClient.requestSerializer.additionalHTTPHeaders[@"Authorization"]).equal([self basicAuthHeaderForTestClient]);
  
  expect(completed).will.beTruthy();
  expect(self.testClient.oauthToken).toNot.beNil();
}

- (void)testAuthenticationWithAppIDAndToken {
  NSDictionary *tokenDict = [self dummyAuthTokenDict];
  PKCRequest *authRequest = [PKCAuthenticationAPI requestForAuthenticationWithAppID:1234 token:@"app-token"];
  [PKCHTTPStubs stubResponseForPath:authRequest.path responseObject:tokenDict];
  
  __block BOOL completed = NO;
  [[self.testClient authenticateAsAppWithID:1234 token:@"app-token"] onSuccess:^(id result) {
    completed = YES;
  }];

  expect(self.testClient.HTTPClient.requestSerializer.additionalHTTPHeaders[@"Authorization"]).equal([self basicAuthHeaderForTestClient]);
  
  expect(completed).will.beTruthy();
  expect(self.testClient.oauthToken).toNot.beNil();
}

- (void)testAuthenticateAutomaticallyWithApp {
  [self.testClient authenticateAutomaticallyAsAppWithID:1234 token:@"app-token"];
  
  NSDictionary *tokenDict = [self dummyAuthTokenDict];
  PKCRequest *authRequest = [PKCAuthenticationAPI requestForAuthenticationWithAppID:1234 token:@"app-token"];
  [PKCHTTPStubs stubResponseForPath:authRequest.path responseObject:tokenDict];
  
  PKCRequest *request = [PKCUsersAPI requestForUserStatus];
  [PKCHTTPStubs stubResponseForPath:request.path statusCode:200];
  
  __block BOOL completed = NO;
  __block BOOL isError = NO;
  [[self.testClient performRequest:request] onSuccess:^(id result) {
    completed = YES;
  } onError:^(NSError *error) {
    completed = YES;
    isError = YES;
  }];
  
  expect(completed).will.beTruthy();
  expect(isError).to.beFalsy();
  expect(self.testClient.oauthToken).toNot.beNil();
}

#pragma mark - Helpers

- (NSDictionary *)dummyAuthTokenDict {
  return [self dummyAuthTokenDictWithExpirationSinceNow:3600];
}

- (NSDictionary *)dummyAuthTokenDictWithExpirationSinceNow:(NSTimeInterval)expiration {
  return @{
    @"access_token" : [[NSUUID UUID] UUIDString],
    @"refresh_token" : [[NSUUID UUID] UUIDString],
    @"expires_in" : @(expiration),
    @"ref" : @{@"key": @"value"}
  };
}

- (PKCOAuth2Token *)dummyAuthToken {
  return [self dummyAuthTokenWithExpirationSinceNow:3600];
}

- (PKCOAuth2Token *)dummyAuthTokenWithExpirationSinceNow:(NSTimeInterval)expiration {
  NSDictionary *dict = [self dummyAuthTokenDictWithExpirationSinceNow:expiration];
  PKCOAuth2Token *token = [[PKCOAuth2Token alloc] initWithDictionary:dict];
  
  return token;
}

- (void)testAuthenticationStateNotificationSentOnTokenChange {
  expect(^{
    self.testClient.oauthToken = [self dummyAuthToken];
  }).to.notify(PKCClientAuthenticationStateDidChangeNotification);
}

- (NSString *)basicAuthHeaderForTestClient {
  return [NSString stringWithFormat:@"Basic %@", [[NSString stringWithFormat:@"%@:%@", self.testClient.apiKey, self.testClient.apiSecret] pkc_base64String]];
}

@end
