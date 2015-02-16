//
//  NSURL+PKCImageURL.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 19/11/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKCFile.h"

@interface NSURL (PKCImageURL)

- (NSURL *)pkc_imageURLForSize:(PKCImageSize)size;

@end
