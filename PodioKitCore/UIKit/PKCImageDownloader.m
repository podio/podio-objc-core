//
//  PKCImageDownloader.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 25/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCImageDownloader.h"
#import "PKCImageCache.h"
#import "PKCFile+UIImage.h"

@implementation PKCImageDownloader

+ (PKCAsyncTask *)setImageWithFile:(PKCFile *)file placeholderImage:(UIImage *)placeholderImage imageSize:(PKCImageSize)imageSize imageSetterBlock:(void (^)(UIImage *image))imageSetterBlock {
  NSParameterAssert(file);
  NSParameterAssert(imageSetterBlock);
  
  // Check for a cached image
  UIImage *image = [[PKCImageCache sharedCache] cachedImageForFile:file];
  if (image) {
    imageSetterBlock(image);
    return nil;
  }
  
  imageSetterBlock(placeholderImage);
  
  PKCAsyncTask *task = [[file downloadImageOfSize:imageSize] then:^(UIImage *image, NSError *error) {
    if (image) {
      [[PKCImageCache sharedCache] setCachedImage:image forFile:file];
      imageSetterBlock(image);
    }
  }];
  
  return task;
}

@end
