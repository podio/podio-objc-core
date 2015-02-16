//
//  PKCFilesAPI.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 01/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCBaseAPI.h"
#import "PKCConstants.h"

@interface PKCFilesAPI : PKCBaseAPI

+ (PKCRequest *)requestToDownloadFileWithURL:(NSURL *)fileURL;
+ (PKCRequest *)requestToDownloadFileWithURL:(NSURL *)fileURL toLocalFileWithPath:(NSString *)filePath;
+ (PKCRequest *)requestToUploadFileWithData:(NSData *)data fileName:(NSString *)fileName;
+ (PKCRequest *)requestToUploadFileWithPath:(NSString *)filePath fileName:(NSString *)fileName;
+ (PKCRequest *)requestToAttachFileWithID:(NSUInteger)fileID referenceID:(NSUInteger)referenceID referenceType:(PKCReferenceType)referenceType;

@end
