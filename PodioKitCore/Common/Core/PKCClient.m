//
//  PKCSessionManager.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 27/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCClient.h"
#import "PKCOAuth2Token.h"
#import "PKCTokenStore.h"
#import "PKCAuthenticationAPI.h"
#import "PKCMacros.h"
#import "NSMutableURLRequest+PKCHeaders.h"
#import "NSError+PKCErrors.h"

NSString * const PKCClientAuthenticationStateDidChangeNotification = @"PKCClientAuthenticationStateDidChangeNotification";

static void * kIsAuthenticatedContext = &kIsAuthenticatedContext;
static NSUInteger const kTokenExpirationLimit = 10 * 60; // 10 minutes

typedef NS_ENUM(NSUInteger, PKCClientAuthRequestPolicy) {
  PKCClientAuthRequestPolicyCancelPrevious = 0,
  PKCClientAuthRequestPolicyIgnore,
};

/**
 *  A pending task represents a request that has been requested to be performed but not yet started.
 *  It might be started immediately or enqueued until the token has been successfully refreshed if expired.
 */
@interface PKCPendingRequest : NSObject

@property (nonatomic, strong, readonly) PKCRequest *request;
@property (nonatomic, copy) PKCRequestCompletionBlock completionBlock;

@end

@implementation PKCPendingRequest {

  /**
   *  A pending task can only be either started or cancelled once, but not both or multiple times.
   */
  dispatch_once_t _performedOnceToken;
}

- (instancetype)initWithRequest:(PKCRequest *)request completion:(PKCRequestCompletionBlock)completion {
  self = [super init];
  if (!self) return nil;
  
  _request = request;
  _completionBlock = [completion copy];
  
  return self;
}

/**
 *  Starts the pending task by requesting an NSURLSessionTask from the HTTP client and then
 *  resuming it.
 *
 *  @param client The HTTP client from which to request the NSURLSessionTask.
 */
- (void)startWithHTTPClient:(PKCHTTPClient *)client {
  dispatch_once(&_performedOnceToken, ^{
    NSURLSessionTask *task = [client taskForRequest:self.request completion:self.completionBlock];
    self.completionBlock = nil;
    
    [task resume];
  });
}

/**
 *  Cancels the pending task by requesting an NSURLSessionTask from the HTTP client and then
 *  immediately cancel it.
 *
 *  @param client The HTTP client from which to request the NSURLSessionTask.
 */
- (void)cancelWithHTTPClient:(PKCHTTPClient *)client {
  dispatch_once(&_performedOnceToken, ^{
    NSURLSessionTask *task = [client taskForRequest:self.request completion:self.completionBlock];
    self.completionBlock = nil;
    
    [task cancel];
  });
}

@end

@interface PKCClient ()

@property (nonatomic, copy, readwrite) NSString *apiKey;
@property (nonatomic, copy, readwrite) NSString *apiSecret;
@property (nonatomic, weak, readwrite) PKCAsyncTask *authenticationTask;
@property (nonatomic, strong, readwrite) PKCRequest *savedAuthenticationRequest;
@property (nonatomic, strong, readonly) NSMutableOrderedSet *pendingRequests;

@end

@implementation PKCClient

@synthesize pendingRequests = _pendingRequests;

+ (instancetype)defaultClient {
  static PKCClient *defaultClient;
  static dispatch_once_t once;
  
  dispatch_once(&once, ^{
    defaultClient = [self new];
  });
  
  return defaultClient;
}

- (id)init {
  PKCHTTPClient *httpClient = [PKCHTTPClient new];
  PKCClient *client = [self initWithHTTPClient:httpClient];
  
  return client;
}

- (instancetype)initWithHTTPClient:(PKCHTTPClient *)client {
  @synchronized(self) {
    self = [super init];
    if (!self) return nil;

    _HTTPClient = client;

    [self updateAuthorizationHeader:self.isAuthenticated];

    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(isAuthenticated)) options:NSKeyValueObservingOptionNew context:kIsAuthenticatedContext];
    
    return self;
  }
}

- (instancetype)initWithAPIKey:(NSString *)key secret:(NSString *)secret {
  PKCClient *client = [self init];
  [client setupWithAPIKey:key secret:secret];
  
  return client;
}

- (void)dealloc {
  [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(isAuthenticated)) context:kIsAuthenticatedContext];
}

#pragma mark - Properties

- (BOOL)isAuthenticated {
  return self.oauthToken != nil;
}

- (void)setOauthToken:(PKCOAuth2Token *)oauthToken {
  if (oauthToken == _oauthToken) return;

  NSString *isAuthenticatedKey = NSStringFromSelector(@selector(isAuthenticated));
  [self willChangeValueForKey:isAuthenticatedKey];

  _oauthToken = oauthToken;

  [self didChangeValueForKey:isAuthenticatedKey];
}

- (NSMutableOrderedSet *)pendingRequests {
  if (!_pendingRequests) {
    _pendingRequests = [[NSMutableOrderedSet alloc] init];
  }
  
  return _pendingRequests;
}

#pragma mark - Clients

+ (void)pushClient:(PKCClient *)client {
  [[self clientStack] addObject:client];
}

+ (void)popClient {
  [[self clientStack] removeLastObject];
}

+ (instancetype)currentClient {
  return [[self clientStack] lastObject] ?: [self defaultClient];
}

+ (NSMutableArray *)clientStack {
  static NSMutableArray *clientStack = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    clientStack = [NSMutableArray new];
  });

  return clientStack;
}

- (void)performBlock:(void (^)(void))block {
  NSParameterAssert(block);

  [[self class] pushClient:self];
  block();
  [[self class] popClient];
}

#pragma mark - Configuration

- (void)setupWithAPIKey:(NSString *)key secret:(NSString *)secret {
  NSParameterAssert(key);
  NSParameterAssert(secret);
  
  self.apiKey = key;
  self.apiSecret = secret;
  
  [self updateAuthorizationHeader:self.isAuthenticated];
}

#pragma mark - Authentication

- (PKCAsyncTask *)authenticateAsUserWithEmail:(NSString *)email password:(NSString *)password {
  NSParameterAssert(email);
  NSParameterAssert(password);

  PKCRequest *request = [PKCAuthenticationAPI requestForAuthenticationWithEmail:email password:password];
  return [self authenticateWithRequest:request requestPolicy:PKCClientAuthRequestPolicyCancelPrevious];
}

- (PKCAsyncTask *)authenticateAsAppWithID:(NSUInteger)appID token:(NSString *)appToken {
  NSParameterAssert(appID);
  NSParameterAssert(appToken);

  PKCRequest *request = [PKCAuthenticationAPI requestForAuthenticationWithAppID:appID token:appToken];
  return [self authenticateWithRequest:request requestPolicy:PKCClientAuthRequestPolicyCancelPrevious];
}

- (void)authenticateAutomaticallyAsAppWithID:(NSUInteger)appID token:(NSString *)appToken {
  NSParameterAssert(appID);
  NSParameterAssert(appToken);
  
  self.savedAuthenticationRequest = [PKCAuthenticationAPI requestForAuthenticationWithAppID:appID token:appToken];
}

- (PKCAsyncTask *)authenticateWithRequest:(PKCRequest *)request requestPolicy:(PKCClientAuthRequestPolicy)requestPolicy {
  if (requestPolicy == PKCClientAuthRequestPolicyIgnore) {
    if (self.authenticationTask) {
      // Ignore this new authentation request, let the old one finish
      return nil;
    }
  } else if (requestPolicy == PKCClientAuthRequestPolicyCancelPrevious) {
    // Cancel any pending authentication task
    [self.authenticationTask cancel];
  }

  PKC_WEAK_SELF weakSelf = self;

  // Always use basic authentication for authentication requests
  request.URLRequestConfigurationBlock = ^NSURLRequest *(NSURLRequest *urlRequest) {
      PKC_STRONG(weakSelf) strongSelf = weakSelf;

      NSMutableURLRequest *mutURLRequest = [urlRequest mutableCopy];
      [mutURLRequest pkc_setAuthorizationHeaderWithUsername:strongSelf.apiKey password:strongSelf.apiSecret];

      return [mutURLRequest copy];
  };

  self.authenticationTask = [[self performTaskWithRequest:request] then:^(PKCResponse *response, NSError *error) {
    PKC_STRONG(weakSelf) strongSelf = weakSelf;
    
    if (!error) {
      strongSelf.oauthToken = [[PKCOAuth2Token alloc] initWithDictionary:response.body];
    } else if ([error pkc_isServerError]) {
      // If authentication failed server side, reset the token since it isn't likely
      // to be successful next time either. If it is NOT a server side error, it might
      // just be networking so we should not reset the token.
      strongSelf.oauthToken = nil;
    }
    
    strongSelf.authenticationTask = nil;
  }];

  return self.authenticationTask;
}

- (PKCAsyncTask *)authenticateWithSavedRequest:(PKCRequest *)request {
  PKCAsyncTask *task = [self authenticateWithRequest:request requestPolicy:PKCClientAuthRequestPolicyIgnore];
  
  PKC_WEAK_SELF weakSelf = self;
  
  task = [task then:^(id result, NSError *error) {
    PKC_STRONG(weakSelf) strongSelf = weakSelf;
    
    if (!error) {
      [strongSelf processPendingRequests];
    } else {
      [strongSelf clearPendingRequests];
    }
  }];
  
  return task;
}

#pragma mark - Requests

- (PKCAsyncTask *)performRequest:(PKCRequest *)request {
  NSAssert(self.apiKey && self.apiSecret, @"You need to configure PodioKit with an API key and secret. Call [PodioKit setupWithAPIKey:secret:] before making any requests using PodioKit.");
  
  PKCAsyncTask *task = nil;
  
  if (self.isAuthenticated) {
    // Authenticated request, might need token refresh
    if (![self.oauthToken willExpireWithinIntervalFromNow:kTokenExpirationLimit]) {
      task = [self performTaskWithRequest:request];
    } else {
      task = [self enqueueTaskWithRequest:request];
      [self refreshToken];
    }
  } else if (self.savedAuthenticationRequest) {
    // Can self-authenticate, authenticate before performing request
    task = [self enqueueTaskWithRequest:request];
    [self authenticateWithSavedRequest:self.savedAuthenticationRequest];
  } else {
    // Unauthenticated request
    task = [self performTaskWithRequest:request];
  }
  
  return task;
}

- (PKCAsyncTask *)performTaskWithRequest:(PKCRequest *)request {
  __block PKCPendingRequest *pendingRequest = nil;
  
  PKC_WEAK_SELF weakSelf = self;
  
  PKCAsyncTask *task = [PKCAsyncTask taskForBlock:^PKCAsyncTaskCancelBlock(PKCAsyncTaskResolver *resolver) {
    pendingRequest = [self pendingRequestForRequest:request taskResolver:resolver];
    
    PKC_WEAK(pendingRequest) weakPendingRequest = pendingRequest;
    
    return ^{
      [weakPendingRequest cancelWithHTTPClient:weakSelf.HTTPClient];
    };
  }];
  
  [pendingRequest startWithHTTPClient:self.HTTPClient];
  
  return task;
}

- (PKCAsyncTask *)enqueueTaskWithRequest:(PKCRequest *)request {
  __block PKCPendingRequest *pendingRequest = nil;
  
  PKC_WEAK_SELF weakSelf = self;
  
  PKCAsyncTask *task = [PKCAsyncTask taskForBlock:^PKCAsyncTaskCancelBlock(PKCAsyncTaskResolver *resolver) {
    pendingRequest = [self pendingRequestForRequest:request taskResolver:resolver];
    
    PKC_WEAK(pendingRequest) weakPendingRequest = pendingRequest;
    
    return ^{
      [weakPendingRequest cancelWithHTTPClient:weakSelf.HTTPClient];
    };
  }];
  
  [self.pendingRequests addObject:pendingRequest];
  
  return task;
}

- (PKCPendingRequest *)pendingRequestForRequest:(PKCRequest *)request taskResolver:(PKCAsyncTaskResolver *)taskResolver {
  PKC_WEAK_SELF weakSelf = self;
  
  return [[PKCPendingRequest alloc] initWithRequest:request completion:^(PKCResponse *response, NSError *error) {
    PKC_STRONG(weakSelf) strongSelf = weakSelf;
    
    if (!error) {
      [taskResolver succeedWithResult:response];
    } else {
      if (response.statusCode == 401) {
        // The token we are using is not valid anymore. Reset it.
        strongSelf.oauthToken = nil;
      }
      
      [taskResolver failWithError:error];
    }
  }];
}

- (void)processPendingRequests {
  for (PKCPendingRequest *request in self.pendingRequests) {
    [request startWithHTTPClient:self.HTTPClient];
  }
  
  [self.pendingRequests removeAllObjects];
}

- (void)clearPendingRequests {
  for (PKCPendingRequest *request in self.pendingRequests) {
    [request cancelWithHTTPClient:self.HTTPClient];
  }
  
  [self.pendingRequests removeAllObjects];
}

#pragma mark - State

- (void)authenticationStateDidChange:(BOOL)isAuthenticated {
  [self updateAuthorizationHeader:isAuthenticated];
  [self updateStoredToken];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:PKCClientAuthenticationStateDidChangeNotification object:self];
}

- (void)updateAuthorizationHeader:(BOOL)isAuthenticated {
  if (isAuthenticated) {
    [self.HTTPClient.requestSerializer setAuthorizationHeaderWithOAuth2AccessToken:self.oauthToken.accessToken];
  } else if (self.apiKey && self.apiSecret) {
    [self.HTTPClient.requestSerializer setAuthorizationHeaderWithAPIKey:self.apiKey secret:self.apiSecret];
  }
}

- (void)updateStoredToken {
  if (!self.tokenStore) return;
  
  PKCOAuth2Token *token = self.oauthToken;
  if (token) {
    [self.tokenStore storeToken:token];
  } else {
    [self.tokenStore deleteStoredToken];
  }
}

- (void)restoreTokenIfNeeded {
  if (!self.tokenStore) return;
  
  if (!self.isAuthenticated) {
    self.oauthToken = [self.tokenStore storedToken];
  }
}

#pragma mark - Refresh token

- (PKCAsyncTask *)refreshTokenWithRefreshToken:(NSString *)refreshToken {
  NSParameterAssert(refreshToken);

  PKCRequest *request = [PKCAuthenticationAPI requestToRefreshToken:refreshToken];
  return [self authenticateWithRequest:request requestPolicy:PKCClientAuthRequestPolicyIgnore];
}

- (PKCAsyncTask *)refreshToken {
  NSAssert([self.oauthToken.refreshToken length] > 0, @"Can't refresh session, refresh token is missing.");

  PKCAsyncTask *task = [self refreshTokenWithRefreshToken:self.oauthToken.refreshToken];
  
  PKC_WEAK_SELF weakSelf = self;
  
  task = [task then:^(id result, NSError *error) {
    PKC_STRONG(weakSelf) strongSelf = weakSelf;
    
    if (!error) {
      [strongSelf processPendingRequests];
    } else {
      [strongSelf clearPendingRequests];
    }
  }];
  
  return task;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (context == kIsAuthenticatedContext) {
    BOOL isAuthenticated = [change[NSKeyValueChangeNewKey] boolValue];
    [self authenticationStateDidChange:isAuthenticated];
  }
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
  BOOL automatic = NO;
  
  NSString *isAuthenticatedKey = NSStringFromSelector(@selector(isAuthenticated));
  if ([theKey isEqualToString:isAuthenticatedKey]) {
    // The "isAuthentication" KVO event is managed manually using willChangeValueForKey:/didChangeValueForKey:
    automatic = NO;
  } else {
    automatic = [super automaticallyNotifiesObserversForKey:theKey];
  }
  
  return automatic;
}

@end
