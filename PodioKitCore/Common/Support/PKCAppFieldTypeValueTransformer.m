//
//  PKCAppFieldTypeValueTransformer.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 09/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCAppFieldTypeValueTransformer.h"
#import "PKCConstants.h"

@implementation PKCAppFieldTypeValueTransformer

- (instancetype)init {
  return [super initWithDictionary:@{
    @"text" : @(PKCAppFieldTypeText),
    @"number" : @(PKCAppFieldTypeNumber),
    @"image" : @(PKCAppFieldTypeImage),
    @"date" : @(PKCAppFieldTypeDate),
    @"app" : @(PKCAppFieldTypeApp),
    @"contact" : @(PKCAppFieldTypeContact),
    @"money" : @(PKCAppFieldTypeMoney),
    @"progress" : @(PKCAppFieldTypeProgress),
    @"location" : @(PKCAppFieldTypeLocation),
    @"duration" : @(PKCAppFieldTypeDuration),
    @"embed" : @(PKCAppFieldTypeEmbed),
    @"calculation" : @(PKCAppFieldTypeCalculation),
    @"category" : @(PKCAppFieldTypeCategory)
  }];
}

@end
