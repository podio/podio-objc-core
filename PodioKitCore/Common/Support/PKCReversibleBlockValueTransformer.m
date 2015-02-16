//
//  PKCReversibleBlockValueTransformer.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 14/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCReversibleBlockValueTransformer.h"

@interface PKCReversibleBlockValueTransformer ()

@property (nonatomic, copy) PKCValueTransformationBlock reverseBlock;

@end

@implementation PKCReversibleBlockValueTransformer

- (instancetype)init {
  return [self initWithBlock:nil reverseBlock:nil];
}

- (instancetype)initWithBlock:(PKCValueTransformationBlock)block reverseBlock:(PKCValueTransformationBlock)reverseBlock {
  self = [super initWithBlock:block];
  if (!self) return nil;
  
  _reverseBlock = [reverseBlock copy];
  
  return self;
}

+ (instancetype)transformerWithBlock:(PKCValueTransformationBlock)block reverseBlock:(PKCValueTransformationBlock)reverseBlock {
  return [[self alloc] initWithBlock:block reverseBlock:reverseBlock];
}

#pragma mark - NSValueTransformer

+ (BOOL)allowsReverseTransformation {
  return YES;
}

- (id)reverseTransformedValue:(id)value {
  return self.reverseBlock ? self.reverseBlock(value) : nil;
}

@end
