//
//  PKCImageCache.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 25/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKCFile;

@interface PKCImageCache : NSCache

+ (instancetype)sharedCache;

- (void)clearCache;

- (UIImage *)cachedImageForFile:(PKCFile *)file;

- (void)setCachedImage:(UIImage *)image forFile:(PKCFile *)file;

@end
