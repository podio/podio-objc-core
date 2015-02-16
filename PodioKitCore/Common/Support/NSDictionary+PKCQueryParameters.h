//
//  NSDictionary+PKCQueryParameters.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 09/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PKCQueryParameters)

- (NSString *)pkc_queryString;
- (NSString *)pkc_escapedQueryString;
- (NSDictionary *)pkc_queryParametersPairs;
- (NSDictionary *)pkc_escapedQueryParametersPairs;

@end
