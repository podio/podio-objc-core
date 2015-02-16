//
//  UIButton+PKCRemoteImage.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 25/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import <UIKit/UIKit.h>
#import "PKCConstants.h"

@class PKCFile;
@class PKCAsyncTask;

@interface UIButton (PKCRemoteImage)

- (PKCAsyncTask *)pkc_setImageWithFile:(PKCFile *)file forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage imageSize:(PKCImageSize)imageSize;
- (PKCAsyncTask *)pkc_setBackgroundImageWithFile:(PKCFile *)file forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage imageSize:(PKCImageSize)imageSize;

- (void)pkc_cancelCurrentImageDownload;
- (void)pkc_cancelCurrentBackgroundImageDownload;

@end

#endif