//
//  PKCDateValueTransformer.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 02/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCReversibleBlockValueTransformer.h"

@interface PKCDateValueTransformer : PKCReversibleBlockValueTransformer

@property (nonatomic, assign) BOOL ignoresTimeComponent;

@end