//
//  PKCFile.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 27/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCFile.h"
#import "PKCFilesAPI.h"
#import "NSURL+PKCImageURL.h"
#import "NSValueTransformer+PKCTransformers.h"

@implementation PKCFile

#pragma mark - PKCModel

+ (NSDictionary *)dictionaryKeyPathsForPropertyNames {
  return @{
           @"fileID" : @"file_id",
           @"mimeType" : @"mimetype",
           @"hostedBy" : @"hosted_by",
           @"link" : @"link",
           @"thumbnailLink" : @"thumbnail_link",
           @"createdOn" : @"created_on"
           };
}

+ (NSValueTransformer *)linkValueTransformer {
  return [NSValueTransformer pkc_URLTransformer];
}

+ (NSValueTransformer *)thumbnailLinkValueTransformer {
  return [NSValueTransformer pkc_URLTransformer];
}

+ (NSValueTransformer *)createdOnValueTransformer {
  return [NSValueTransformer pkc_dateValueTransformer];
}

#pragma mrk - API

+ (PKCAsyncTask *)uploadWithData:(NSData *)data fileName:(NSString *)fileName {
  PKCRequest *request = [PKCFilesAPI requestToUploadFileWithData:data fileName:fileName];
  PKCAsyncTask *requestTask = [[PKCClient currentClient] performRequest:request];
  
  Class klass = [self class];
  
  PKCAsyncTask *task = [requestTask map:^id(PKCResponse *response) {
    return [[klass alloc] initWithDictionary:response.body];
  }];

  return task;
}

+ (PKCAsyncTask *)uploadWithPath:(NSString *)filePath fileName:(NSString *)fileName {
  PKCRequest *request = [PKCFilesAPI requestToUploadFileWithPath:filePath fileName:fileName];
  PKCAsyncTask *requestTask = [[PKCClient currentClient] performRequest:request];
  
  Class klass = [self class];
  
  PKCAsyncTask *task = [requestTask map:^id(PKCResponse *response) {
    return [[klass alloc] initWithDictionary:response.body];
  }];
  
  return task;
}

- (PKCAsyncTask *)attachWithReferenceID:(NSUInteger)referenceID referenceType:(PKCReferenceType)referenceType {
  PKCRequest *request = [PKCFilesAPI requestToAttachFileWithID:self.fileID referenceID:referenceID referenceType:referenceType];
  PKCAsyncTask *task = [[PKCClient currentClient] performRequest:request];

  return task;
}

+ (PKCAsyncTask *)downloadFileWithURL:(NSURL *)fileURL {
  NSParameterAssert(fileURL);
  
  PKCRequest *request = [PKCFilesAPI requestToDownloadFileWithURL:fileURL];
  PKCAsyncTask *requestTask = [[PKCClient currentClient] performRequest:request];
  
  PKCAsyncTask *task = [requestTask map:^id(PKCResponse *response) {
    return response.body;
  }];
  
  return task;
}

+ (PKCAsyncTask *)downloadFileWithURL:(NSURL *)fileURL toFileWithPath:(NSString *)filePath {
  NSParameterAssert(fileURL);
  
  PKCRequest *request = [PKCFilesAPI requestToDownloadFileWithURL:fileURL toLocalFileWithPath:filePath];
  PKCAsyncTask *task = [[PKCClient currentClient] performRequest:request];
  
  return task;
}

- (PKCAsyncTask *)download {
  return [[self class] downloadFileWithURL:self.link];
}

- (PKCAsyncTask *)downloadToFileWithPath:(NSString *)filePath {
  return [[self class] downloadFileWithURL:self.link toFileWithPath:filePath];
}

- (NSURL *)downloadURLForImageSize:(PKCImageSize)imageSize {
  NSParameterAssert(self.link);
  
  return [self.link pkc_imageURLForSize:imageSize];
}

@end
