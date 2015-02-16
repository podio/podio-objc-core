//
//  PKCFile+UIImage.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 25/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import "PKCFile+UIImage.h"
#import "PKCFilesAPI.h"
#import "PKCMacros.h"
#import "NSURL+PKCImageURL.h"

@implementation PKCFile (UIImage)

- (PKCAsyncTask *)downloadImage {
  return [self downloadImageOfSize:PKCImageSizeOriginal];
}

- (PKCAsyncTask *)downloadImageOfSize:(PKCImageSize)imageSize {
  NSParameterAssert(self.link);
  
  NSURL *imageURL = [self.link pkc_imageURLForSize:imageSize];
  PKCRequest *request = [PKCFilesAPI requestToDownloadFileWithURL:imageURL];
  PKCAsyncTask *requestTask = [[PKCClient currentClient] performRequest:request];
  
  PKCAsyncTask *task = [PKCAsyncTask taskForBlock:^PKCAsyncTaskCancelBlock(PKCAsyncTaskResolver *resolver) {
    
    [requestTask onSuccess:^(PKCResponse *response) {
      // Dispatch the loading of the image from NSData to a background thread for better performance
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [UIImage imageWithData:response.body];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [resolver succeedWithResult:image];
        });
      });
    } onError:^(NSError *error) {
      [resolver failWithError:error];
    }];
    
    PKC_WEAK(requestTask) weakTask = requestTask;
    
    return ^{
      [weakTask cancel];
    };
  }];
  
  return task;
}

@end

#endif