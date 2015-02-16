//
//  NSArray+PKCAdditions.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 01/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (PKCAdditions)

- (instancetype)pkc_mappedArrayWithBlock:(id (^)(id obj))block;
- (instancetype)pkc_filteredArrayWithBlock:(BOOL (^)(id obj))block;
- (id)pkc_reducedValueWithBlock:(id (^)(id reduced, id obj))block;
- (id)pkc_firstObjectPassingTest:(BOOL (^)(id obj))block;
+ (instancetype)pkc_arrayFromRange:(NSRange)range;

@end
