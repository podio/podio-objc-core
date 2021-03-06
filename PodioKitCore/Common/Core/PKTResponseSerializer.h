//
//  PKTResponseSerializer.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 09/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKTResponseSerializer : NSObject

- (id)responseObjectForURLResponse:(NSURLResponse *)response data:(NSData *)data;

@end
