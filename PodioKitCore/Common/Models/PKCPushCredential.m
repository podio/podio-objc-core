//
//  PKCPushCredential.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 28/10/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCPushCredential.h"
#import "NSValueTransformer+PKCTransformers.h"

@implementation PKCPushCredential

#pragma mark - PKCModel

+ (NSDictionary *)dictionaryKeyPathsForPropertyNames {
  return @{ @"expiresOn": @"expires_in" };
}

+ (NSValueTransformer *)expiresOnValueTransformer {
  return [NSValueTransformer pkc_transformerWithBlock:^id(NSNumber *expiresIn) {
    return [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
  }];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
  // Since this object is immutable, just return the same instance
  return self;
}

@end
