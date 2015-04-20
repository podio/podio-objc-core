//
//  PKCRequestSerializer.m
//  PodioKit
//
//  Created by Romain Briche on 22/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCRequestSerializer.h"
#import "PKCRequest.h"
#import "PKCMultipartFormData.h"
#import "NSString+PKCRandom.h"
#import "NSString+PKCBase64.h"
#import "NSURL+PKCAdditions.h"
#import "NSDictionary+PKCQueryParameters.h"

static NSString * const kHTTPMethodGET = @"GET";
static NSString * const kHTTPMethodPOST = @"POST";
static NSString * const kHTTPMethodPUT = @"PUT";
static NSString * const kHTTPMethodDELETE = @"DELETE";
static NSString * const kHTTPMethodHEAD = @"HEAD";

NSString * const PKCRequestSerializerHTTPHeaderKeyAuthorization = @"Authorization";
NSString * const PKCRequestSerializerHTTPHeaderKeyUserAgent = @"User-Agent";
NSString * const PKCRequestSerializerHTTPHeaderKeyContentType = @"Content-Type";
NSString * const PKCRequestSerializerHTTPHeaderKeyContentLength = @"Content-Length";


static NSString * const kHeaderRequestId = @"X-Podio-Request-Id";
static NSUInteger const kRequestIdLength = 8;

static NSString * const kAuthorizationOAuth2AccessTokenFormat = @"OAuth2 %@";

static NSString * const kHeaderTimeZone = @"X-Time-Zone";

static NSString * const kBoundaryPrefix = @"----------------------";
static NSUInteger const kBoundaryLength = 20;

@interface PKCRequestSerializer ()

@property (nonatomic, assign) PKCRequestContentType requestContentType;
@property (nonatomic, copy, readonly) NSString *boundary;
@property (nonatomic, strong, readonly) NSMutableDictionary *mutAdditionalHTTPHeaders;

@end

@implementation PKCRequestSerializer

@synthesize boundary = _boundary;
@synthesize mutAdditionalHTTPHeaders = _mutAdditionalHTTPHeaders;

- (NSString *)boundary {
  if (!_boundary) {
    _boundary = [NSString stringWithFormat:@"%@%@", kBoundaryPrefix, [NSString pkc_randomHexStringOfLength:kBoundaryLength]];
  }
  
  return _boundary;
}

- (NSMutableDictionary *)mutAdditionalHTTPHeaders {
  if (!_mutAdditionalHTTPHeaders) {
    _mutAdditionalHTTPHeaders = [NSMutableDictionary new];
  }
  
  return _mutAdditionalHTTPHeaders;
}

- (NSDictionary *)additionalHTTPHeaders {
  return [self.mutAdditionalHTTPHeaders copy];
}

#pragma mark Public

- (id)valueForHTTPHeader:(NSString *)header {
  return [self additionalHTTPHeaders][header];
}

- (void)setValue:(NSString *)value forHTTPHeader:(NSString *)header {
  NSParameterAssert(header);
  
  if (value) {
    self.mutAdditionalHTTPHeaders[header] = value;
  } else {
    [self.mutAdditionalHTTPHeaders removeObjectForKey:header];
  }
}

- (void)setAuthorizationHeaderWithOAuth2AccessToken:(NSString *)accessToken {
  NSParameterAssert(accessToken);
  [self setValue:[NSString stringWithFormat:kAuthorizationOAuth2AccessTokenFormat, accessToken] forHTTPHeader:PKCRequestSerializerHTTPHeaderKeyAuthorization];
}

- (void)setAuthorizationHeaderWithAPIKey:(NSString *)key secret:(NSString *)secret {
  NSParameterAssert(key);
  NSParameterAssert(secret);
  
  NSString *credentials = [NSString stringWithFormat:@"%@:%@", key, secret];
  [self setValue:[NSString stringWithFormat:@"Basic %@", [credentials pkc_base64String]] forHTTPHeader:PKCRequestSerializerHTTPHeaderKeyAuthorization];
}

- (void)setUserAgentHeader:(NSString *)userAgent {
  NSParameterAssert(userAgent);
  [self setValue:userAgent forHTTPHeader:PKCRequestSerializerHTTPHeaderKeyUserAgent];
}

#pragma mark - URL request

- (NSMutableURLRequest *)URLRequestForRequest:(PKCRequest *)request relativeToURL:(NSURL *)baseURL {
  return [self URLRequestForRequest:request multipartData:nil relativeToURL:baseURL];
}

- (NSMutableURLRequest *)URLRequestForRequest:(PKCRequest *)request multipartData:(PKCMultipartFormData *)multipartData relativeToURL:(NSURL *)baseURL {
  NSParameterAssert(request);
  NSParameterAssert(baseURL);
  
  NSURL *url = nil;
  if (request.URL) {
    url = request.URL;
  } else {
    NSParameterAssert(request.path);
    url = [NSURL URLWithString:request.path relativeToURL:baseURL];
  }
  
  if (request.parameters && [[self class] supportsQueryParametersForRequestMethod:request.method]) {
    url = [url pkc_URLByAppendingQueryParameters:request.parameters];
  }
  
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
  urlRequest.HTTPMethod = [[self class] HTTPMethodForMethod:request.method];
  [urlRequest setValue:[[self class] generatedRequestId] forHTTPHeaderField:kHeaderRequestId];
  [urlRequest setValue:[self contentTypeForRequest:request] forHTTPHeaderField:PKCRequestSerializerHTTPHeaderKeyContentType];
  [urlRequest setValue:[[NSTimeZone localTimeZone] name] forHTTPHeaderField:kHeaderTimeZone];
  
  if (multipartData) {
    NSString *contentLength = [NSString stringWithFormat:@"%lu", (unsigned long)multipartData.finalizedData.length];
    [urlRequest setValue:contentLength forHTTPHeaderField:PKCRequestSerializerHTTPHeaderKeyContentLength];
  }
  
  [self.additionalHTTPHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *header, NSString *value, BOOL *stop) {
    [urlRequest setValue:value forHTTPHeaderField:header];
  }];
  
  urlRequest.HTTPBody = [[self class] bodyDataForRequest:request];
  
  if (request.URLRequestConfigurationBlock) {
    urlRequest = [request.URLRequestConfigurationBlock(urlRequest) mutableCopy];
  }
  
  return urlRequest;
}

- (PKCMultipartFormData *)multipartFormDataFromRequest:(PKCRequest *)request {
  PKCMultipartFormData *multiPartData = [PKCMultipartFormData multipartFormDataWithBoundary:self.boundary encoding:NSUTF8StringEncoding];
  
  if (request.fileData.data) {
    [multiPartData appendFileData:request.fileData.data fileName:request.fileData.fileName mimeType:nil name:request.fileData.name];
  } else if (request.fileData.filePath) {
    [multiPartData appendContentsOfFileAtPath:request.fileData.filePath name:request.fileData.name];
  }
  
  if ([request.parameters count] > 0) {
    [multiPartData appendFormDataParameters:request.parameters];
  }
  
  [multiPartData finalizeData];

  return multiPartData;
}

#pragma mark - Private

+ (NSString *)generatedRequestId {
  return [NSString pkc_randomHexStringOfLength:kRequestIdLength];
}

+ (NSString *)HTTPMethodForMethod:(PKCRequestMethod)method {
  NSString *string = nil;

  switch (method) {
    case PKCRequestMethodGET:
      string = kHTTPMethodGET;
      break;
    case PKCRequestMethodPOST:
      string = kHTTPMethodPOST;
      break;
    case PKCRequestMethodPUT:
      string = kHTTPMethodPUT;
      break;
    case PKCRequestMethodDELETE:
      string = kHTTPMethodDELETE;
      break;
    case PKCRequestMethodHEAD:
      string = kHTTPMethodHEAD;
      break;
    default:
      break;
  }

  return string;
}

+ (NSData *)bodyDataForRequest:(PKCRequest *)request {
  NSData *data = nil;
  
  if (request.parameters && ![self supportsQueryParametersForRequestMethod:request.method]) {
    if (request.contentType == PKCRequestContentTypeJSON) {
      data = [NSJSONSerialization dataWithJSONObject:request.parameters options:0 error:nil];
    } else if (request.contentType == PKCRequestContentTypeFormURLEncoded) {
      data = [[request.parameters pkc_escapedQueryString] dataUsingEncoding:NSUTF8StringEncoding];
    }
  }
  
  return data;
}

+ (BOOL)supportsQueryParametersForRequestMethod:(PKCRequestMethod)method {
  return method == PKCRequestMethodGET || method == PKCRequestMethodDELETE || method == PKCRequestMethodHEAD;
}

- (NSString *)contentTypeForRequest:(PKCRequest *)request {
  NSString *contentType = nil;
  
  static NSString *charset = nil;
  static dispatch_once_t charsetToken;
  dispatch_once(&charsetToken, ^{
    charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
  });
  
  switch (request.contentType) {
    case PKCRequestContentTypeMultipart:
      contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary];
      break;
    case PKCRequestContentTypeFormURLEncoded:
      contentType = [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset];
      break;
    case PKCRequestContentTypeJSON:
      contentType = [NSString stringWithFormat:@"application/json; charset=%@", charset];
    default:
      
      break;
  }
  
  return contentType;
}

@end
