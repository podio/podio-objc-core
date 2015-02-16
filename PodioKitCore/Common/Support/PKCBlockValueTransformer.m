//
//  PKCBlockValueTransformer.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 14/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCBlockValueTransformer.h"

@interface PKCBlockValueTransformer ()

@property (nonatomic, copy) PKCValueTransformationBlock transformBlock;

@end

@implementation PKCBlockValueTransformer

- (instancetype)init {
  return [self initWithBlock:nil];
}

- (instancetype)initWithBlock:(PKCValueTransformationBlock)block {
  self = [super init];
  if (!self) return nil;
  
  _transformBlock = [block copy];
  
  return self;
}

+ (instancetype)transformerWithBlock:(PKCValueTransformationBlock)block {
  return [[self alloc] initWithBlock:block];
}

#pragma mark - NSValueTransformer

+ (BOOL)allowsReverseTransformation {
  return NO;
}

- (id)transformedValue:(id)value {
  return self.transformBlock ? self.transformBlock(value) : nil;
}

@end
