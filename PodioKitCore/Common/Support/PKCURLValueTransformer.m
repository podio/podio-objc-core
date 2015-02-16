//
//  PKCURLValueTransformer.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 22/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCURLValueTransformer.h"

@implementation PKCURLValueTransformer

- (instancetype)init {
  return [super initWithBlock:^id(NSString *URLString) {
    return [NSURL URLWithString:URLString];
  }];
}

@end
