//
//  PKCImageDownloader.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 25/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKCConstants.h"

@class PKCFile;
@class PKCAsyncTask;

@interface PKCImageDownloader : NSObject

+ (PKCAsyncTask *)setImageWithFile:(PKCFile *)file placeholderImage:(UIImage *)placeholderImage imageSize:(PKCImageSize)imageSize imageSetterBlock:(void (^)(UIImage *image))imageSetterBlock;

@end
