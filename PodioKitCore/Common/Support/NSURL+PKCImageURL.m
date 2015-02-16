//
//  NSURL+PKCImageURL.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 19/11/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "NSURL+PKCImageURL.h"

@implementation NSURL (PKCImageURL)

- (NSURL *)pkc_imageURLForSize:(PKCImageSize)size {
  NSURL *url = [self copy];
  
  NSString *sizeString = nil;
  switch (size) {
    case PKCImageSizeDefault:
      sizeString = @"default";
      break;
    case PKCImageSizeTiny:
      sizeString = @"tiny";
      break;
    case PKCImageSizeSmall:
      sizeString = @"small";
      break;
    case PKCImageSizeMedium:
      sizeString = @"medium";
      break;
    case PKCImageSizeLarge:
      sizeString = @"large";
      break;
    case PKCImageSizeExtraLarge:
      sizeString = @"extra_large";
      break;
    default:
      break;
  }
  
  if (sizeString) {
    // Append x2 since most iOS devices are retina
    sizeString = [sizeString stringByAppendingString:@"_x2"];
    url = [url URLByAppendingPathComponent:sizeString];
  }
  
  return url;
}

@end
