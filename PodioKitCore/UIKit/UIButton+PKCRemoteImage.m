//
//  UIButton+PKCRemoteImage.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 25/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import <objc/runtime.h>
#import "UIButton+PKCRemoteImage.h"
#import "PKCImageDownloader.h"
#import "PKCMacros.h"
#import "PKCAsyncTask.h"

static const char kCurrentImageTaskKey;
static const char kCurrentBackgroundImageTaskKey;

@interface UIButton ()

@property (nonatomic, strong, setter = pkc_setCurrentImageTask:) PKCAsyncTask *pkc_currentImageTask;
@property (nonatomic, strong, setter = pkc_setCurrentBackgroundImageTask:) PKCAsyncTask *pkc_currentBackgroundImageTask;

@end

@implementation UIButton (PKCRemoteImage)

- (PKCAsyncTask *)pkc_currentImageTask {
  return objc_getAssociatedObject(self, &kCurrentImageTaskKey);
}

- (void)pkc_setCurrentImageTask:(PKCAsyncTask *)pkc_currentImageTask {
  objc_setAssociatedObject(self, &kCurrentImageTaskKey, pkc_currentImageTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PKCAsyncTask *)pkc_currentBackgroundImageTask {
  return objc_getAssociatedObject(self, &kCurrentBackgroundImageTaskKey);
}

- (void)pkc_setCurrentBackgroundImageTask:(PKCAsyncTask *)pkc_currentBackgroundImageTask {
  objc_setAssociatedObject(self, &kCurrentBackgroundImageTaskKey, pkc_currentBackgroundImageTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Public

- (PKCAsyncTask *)pkc_setImageWithFile:(PKCFile *)file forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage imageSize:(PKCImageSize)imageSize {
  [self pkc_cancelCurrentImageDownload];
  
  PKC_WEAK_SELF weakSelf = self;
  self.pkc_currentImageTask = [[PKCImageDownloader setImageWithFile:file placeholderImage:placeholderImage imageSize:imageSize imageSetterBlock:^(UIImage *image) {
    [weakSelf setImage:image forState:state];
  }] then:^(id result, NSError *error) {
    weakSelf.pkc_currentImageTask = nil;
  }];
  
  return self.pkc_currentImageTask;
}

- (PKCAsyncTask *)pkc_setBackgroundImageWithFile:(PKCFile *)file forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage imageSize:(PKCImageSize)imageSize {
  [self pkc_cancelCurrentBackgroundImageDownload];
  
  PKC_WEAK_SELF weakSelf = self;
  self.pkc_currentBackgroundImageTask = [[PKCImageDownloader setImageWithFile:file placeholderImage:placeholderImage imageSize:imageSize imageSetterBlock:^(UIImage *image) {
    [weakSelf setBackgroundImage:image forState:state];
  }] then:^(id result, NSError *error) {
    weakSelf.pkc_currentBackgroundImageTask = nil;
  }];
  
  return self.pkc_currentBackgroundImageTask;
}

- (void)pkc_cancelCurrentImageDownload {
  [self.pkc_currentImageTask cancel];
  self.pkc_currentImageTask = nil;
}

- (void)pkc_cancelCurrentBackgroundImageDownload {
  [self.pkc_currentBackgroundImageTask cancel];
  self.pkc_currentBackgroundImageTask = nil;
}


@end

#endif