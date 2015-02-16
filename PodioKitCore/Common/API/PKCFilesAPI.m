//
//  PKCFilesAPI.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 01/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCFilesAPI.h"
#import "NSValueTransformer+PKCConstants.h"

@implementation PKCFilesAPI

+ (PKCRequest *)requestToDownloadFileWithURL:(NSURL *)fileURL {
  return [self requestToDownloadFileWithURL:fileURL toLocalFileWithPath:nil];
}

+ (PKCRequest *)requestToDownloadFileWithURL:(NSURL *)fileURL toLocalFileWithPath:(NSString *)filePath {
  PKCRequest *request = [PKCRequest GETRequestWithURL:fileURL parameters:nil];
  
  if ([filePath length] > 0) {
    request.fileData = [PKCRequestFileData fileDataWithFilePath:filePath name:nil fileName:nil];
  }
  
  return request;
}

+ (PKCRequest *)requestToUploadFileWithData:(NSData *)data fileName:(NSString *)fileName {
  PKCRequest *request = [PKCRequest POSTRequestWithPath:@"/file/" parameters:@{@"filename" : fileName}];
  request.contentType = PKCRequestContentTypeMultipart;
  request.fileData = [PKCRequestFileData fileDataWithData:data name:@"source" fileName:fileName];
  
  return request;
}

+ (PKCRequest *)requestToUploadFileWithPath:(NSString *)filePath fileName:(NSString *)fileName {
  PKCRequest *request = [PKCRequest POSTRequestWithPath:@"/file/" parameters:@{@"filename" : fileName}];
  request.contentType = PKCRequestContentTypeMultipart;
  request.fileData = [PKCRequestFileData fileDataWithFilePath:filePath name:@"source" fileName:fileName];
  
  return request;
}

+ (PKCRequest *)requestToAttachFileWithID:(NSUInteger)fileID referenceID:(NSUInteger)referenceID referenceType:(PKCReferenceType)referenceType {
  NSDictionary *parameters = @{
    @"ref_type" : [NSValueTransformer pkc_stringFromReferenceType:referenceType],
    @"ref_id" : @(referenceID),
  };
  
  NSString *path = PKCRequestPath(@"/file/%lu/attach", (unsigned long)fileID);
  PKCRequest *request = [PKCRequest POSTRequestWithPath:path parameters:parameters];
  
  return request;
}

@end
