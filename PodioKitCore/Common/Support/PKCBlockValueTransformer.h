//
//  PKCBlockValueTransformer.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 14/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^PKCValueTransformationBlock) (id value);

@interface PKCBlockValueTransformer : NSValueTransformer

- (instancetype)initWithBlock:(PKCValueTransformationBlock)block;

+ (instancetype)transformerWithBlock:(PKCValueTransformationBlock)block;

@end
