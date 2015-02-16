//
//  PKCReversibleBlockValueTransformer.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 14/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCBlockValueTransformer.h"

@interface PKCReversibleBlockValueTransformer : PKCBlockValueTransformer

- (instancetype)initWithBlock:(PKCValueTransformationBlock)block reverseBlock:(PKCValueTransformationBlock)reverseBlock;

+ (instancetype)transformerWithBlock:(PKCValueTransformationBlock)block reverseBlock:(PKCValueTransformationBlock)reverseBlock;

@end
