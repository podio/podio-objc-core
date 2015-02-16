//
//  NSDictionary+PKCAdditions.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 11/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PKCAdditions)

- (id)pkc_nonNullObjectForKey:(id)key;

@end
