//
//  PKCFile+UIImage.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 25/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import <UIKit/UIKit.h>
#import "PKCFile.h"

@interface PKCFile (UIImage)

/**
 *  Download the file as an UIImage.
 *
 *  @return A task
 */
- (PKCAsyncTask *)downloadImage;

/**
 *  Download the file as an UIImage of a given size.
 *
 *  @return A task
 */
- (PKCAsyncTask *)downloadImageOfSize:(PKCImageSize)imageSize;

@end

#endif