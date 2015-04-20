//
//  PKCClient.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 16/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCHTTPClient.h"
#import "PKCURLSessionTaskDelegate.h"
#import "PKCMultipartFormData.h"
#import "PKCSecurity.h"
#import "PKCMacros.h"

static NSString * const kDefaultBaseURLString = @"https://api.podio.com";
static char * const kRequestProcessingQueueLabel = "com.podio.podiokit.httpclient.response_processing_queue";

typedef NS_ENUM(NSUInteger, PKCErrorCode) {
  PKCErrorCodeUnknown = 1000,
  PKCErrorCodeRequestFailed,
};

@interface PKCHTTPClient () <NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, strong, readonly) dispatch_queue_t responseProcessingQueue;
@property (nonatomic, strong) NSOperationQueue *delegateQueue;
@property (nonatomic, strong) NSMutableDictionary *taskDelegates;
@property (nonatomic, strong) NSLock *taskDelegatesLock;
@property (nonatomic, copy, readonly) PKCSecurity *security;

@end

@implementation PKCHTTPClient

@synthesize session = _session;
@synthesize requestSerializer = _requestSerializer;
@synthesize responseSerializer = _responseSerializer;
@synthesize security = _security;

- (instancetype)init {
  self = [super init];
  if (!self) return nil;
  
  _baseURL = [[NSURL alloc] initWithString:kDefaultBaseURLString];
  _responseProcessingQueue = dispatch_queue_create(kRequestProcessingQueueLabel, DISPATCH_QUEUE_CONCURRENT);
  _requestSerializer = [PKCRequestSerializer new];
  _responseSerializer = [PKCResponseSerializer new];
  _taskDelegates = [NSMutableDictionary new];
  _taskDelegatesLock = [NSLock new];
  
  NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
  sessionConfig.HTTPShouldUsePipelining = YES;
  
  self.delegateQueue = [NSOperationQueue new];
  self.delegateQueue.maxConcurrentOperationCount = 1;
  
  _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:self.delegateQueue];
  
  return self;
}

#pragma mark - Properties

- (NSString *)userAgent {
  return [self.requestSerializer valueForHTTPHeader:PKCRequestSerializerHTTPHeaderKeyUserAgent];
}

- (void)setUserAgent:(NSString *)userAgent {
  [self.requestSerializer setUserAgentHeader:userAgent];
}

#pragma mark - Private

- (PKCSecurity *)security {
  if (!_security) {
    _security = [PKCSecurity new];
  }
  
  return _security;
}

- (void)addTaskDelegate:(PKCURLSessionTaskDelegate *)delegate forTask:(NSURLSessionTask *)task {
  NSParameterAssert(delegate);
  [self.taskDelegatesLock lock];
  self.taskDelegates[@(task.taskIdentifier)] = delegate;
  [self.taskDelegatesLock unlock];
}

- (void)removeDelegateForTask:(NSURLSessionTask *)task {
  [self.taskDelegatesLock lock];
  [self.taskDelegates removeObjectForKey:@(task.taskIdentifier)];
  [self.taskDelegatesLock unlock];
}

- (PKCURLSessionTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
  return self.taskDelegates[@(task.taskIdentifier)];
}

#pragma mark - Public

- (NSURLSessionTask *)taskForRequest:(PKCRequest *)request progress:(PKCRequestProgressBlock)progress completion:(PKCRequestCompletionBlock)completion {
  NSURLSessionTask *task = nil;
  
  PKCHTTPResponseProcessBlock responseProcessBlock = nil;
  
  if (request.fileData && (request.method == PKCRequestMethodPOST || request.method == PKCRequestMethodPUT)) {
    // Upload task
    PKCMultipartFormData *multipartData = [self.requestSerializer multipartFormDataFromRequest:request];
    NSData *data = [multipartData finalizedData];
    
    NSMutableURLRequest *URLRequest = [self.requestSerializer URLRequestForRequest:request multipartData:multipartData relativeToURL:self.baseURL];
    
    PKC_WEAK(self.responseSerializer) weakResponseSerializer = self.responseSerializer;
    responseProcessBlock = ^(NSURLResponse *URLResponse, NSData *data, PKCURLSessionTaskDelegate *delegate) {
      return [weakResponseSerializer responseObjectForURLResponse:URLResponse data:data];
    };
    
    task = [self.session uploadTaskWithRequest:URLRequest fromData:data];
  } else {
    NSMutableURLRequest *URLRequest = [self.requestSerializer URLRequestForRequest:request relativeToURL:self.baseURL];
    
    if (request.fileData && request.method == PKCRequestMethodGET) {
      // Download task
      
      task = [self.session downloadTaskWithRequest:URLRequest];
    } else {
      // Regular data task
      task = [self.session dataTaskWithRequest:URLRequest];
      
      PKC_WEAK(self.responseSerializer) weakResponseSerializer = self.responseSerializer;
      responseProcessBlock = ^(NSURLResponse *URLResponse, NSData *data, PKCURLSessionTaskDelegate *delegate) {
        return [weakResponseSerializer responseObjectForURLResponse:URLResponse data:data];
      };
    }
  }
  
  PKCURLSessionTaskDelegate *taskDelegate = [[PKCURLSessionTaskDelegate alloc] initWithRequest:request
                                                                       responseProcessingQueue:self.responseProcessingQueue
                                                                                 progressBlock:progress
                                                                          responseProcessBlock:responseProcessBlock
                                                                               completionBlock:completion];
  [self addTaskDelegate:taskDelegate forTask:task];
  
  return task;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
  NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
  NSURLCredential *credential = nil;
  
  if (self.useSSLPinning && [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
    SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
    BOOL isTrustValid = [self.security evaluateServerTrust:serverTrust];
    
    if (isTrustValid) {
      credential = [NSURLCredential credentialForTrust:serverTrust];
      if (credential) {
        disposition = NSURLSessionAuthChallengeUseCredential;
      }
    } else {
      disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
  }
  
  if (completionHandler) {
    completionHandler(disposition, credential);
  }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  PKCURLSessionTaskDelegate *taskDelegate = [self delegateForTask:task];
  [taskDelegate task:task didCompleteWithError:error];
  [self removeDelegateForTask:task];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
  PKCURLSessionTaskDelegate *taskDelegate = [self delegateForTask:dataTask];
  [taskDelegate task:dataTask didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
  PKCURLSessionTaskDelegate *taskDelegate = [self delegateForTask:task];
  [taskDelegate taskDidUpdateProgress:task];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  PKCURLSessionTaskDelegate *taskDelegate = self.taskDelegates[@(downloadTask.taskIdentifier)];
  [taskDelegate taskDidUpdateProgress:downloadTask];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
  PKCURLSessionTaskDelegate *taskDelegate = [self delegateForTask:downloadTask];
  [taskDelegate task:downloadTask didFinishDownloadingToURL:location];
}

@end