//
//  UIImageView+PKCRemoteImage.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 25/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//


#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import <objc/runtime.h>
#import "UIImageView+PKCRemoteImage.h"
#import "PKCImageDownloader.h"
#import "PKCMacros.h"
#import "PKCAsyncTask.h"

static const char kCurrentImageTaskKey;

@interface UIImageView ()

@property (nonatomic, strong, setter = pkc_setCurrentImageTask:) PKCAsyncTask *pkc_currentImageTask;

@end

@implementation UIImageView (PKCRemoteImage)

- (PKCAsyncTask *)pkc_currentImageTask {
  return objc_getAssociatedObject(self, &kCurrentImageTaskKey);
}

- (void)pkc_setCurrentImageTask:(PKCAsyncTask *)pkc_currentImageTask {
  objc_setAssociatedObject(self, &kCurrentImageTaskKey, pkc_currentImageTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Public

- (PKCAsyncTask *)pkc_setImageWithFile:(PKCFile *)file placeholderImage:(UIImage *)placeholderImage imageSize:(PKCImageSize)imageSize {
  [self pkc_cancelCurrentImageDownload];
  
  if (!file) {
    self.image = nil;
    return nil;
  }
  
  PKC_WEAK_SELF weakSelf = self;
  self.pkc_currentImageTask = [[PKCImageDownloader setImageWithFile:file placeholderImage:placeholderImage imageSize:imageSize imageSetterBlock:^(UIImage *image) {
    weakSelf.image = image;
  }] then:^(id result, NSError *error) {
    weakSelf.pkc_currentImageTask = nil;
  }];
  
  return self.pkc_currentImageTask;
}

- (void)pkc_cancelCurrentImageDownload {
  [self.pkc_currentImageTask cancel];
  self.pkc_currentImageTask = nil;
}

@end

#endif
