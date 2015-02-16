//
//  NSObject+PKCIntrospection.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 14/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PKCIntrospection)

+ (id)pkc_valueByPerformingSelectorWithName:(NSString *)selectorName;

+ (id)pkc_valueByPerformingSelectorWithName:(NSString *)selectorName withObject:(id)object;

@end
