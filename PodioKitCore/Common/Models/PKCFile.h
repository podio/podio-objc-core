//
//  PKCFile.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 27/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCModel.h"
#import "PKCClient.h"
#import "PKCConstants.h"

@interface PKCFile : PKCModel

@property (nonatomic, assign, readonly) NSUInteger fileID;
@property (nonatomic, assign, readonly) NSUInteger size;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *description;
@property (nonatomic, copy, readonly) NSString *mimeType;
@property (nonatomic, copy, readonly) NSString *hostedBy;
@property (nonatomic, copy, readonly) NSURL *link;
@property (nonatomic, copy, readonly) NSURL *thumbnailLink;
@property (nonatomic, copy, readonly) NSDate *createdOn;

#pragma mrk - API

+ (PKCAsyncTask *)uploadWithData:(NSData *)data fileName:(NSString *)fileName;

+ (PKCAsyncTask *)uploadWithPath:(NSString *)filePath fileName:(NSString *)fileName;

- (PKCAsyncTask *)attachWithReferenceID:(NSUInteger)referenceID referenceType:(PKCReferenceType)referenceType;

+ (PKCAsyncTask *)downloadFileWithURL:(NSURL *)fileURL;

+ (PKCAsyncTask *)downloadFileWithURL:(NSURL *)fileURL toFileWithPath:(NSString *)filePath;

- (PKCAsyncTask *)download;

- (PKCAsyncTask *)downloadToFileWithPath:(NSString *)filePath;

- (NSURL *)downloadURLForImageSize:(PKCImageSize)imageSize;

@end
