//
//  PKCUsersAPI.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 17/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCUsersAPI.h"

@implementation PKCUsersAPI

+ (PKCRequest *)requestForUserStatus {
  return [PKCRequest GETRequestWithPath:@"/user/status" parameters:nil];
}

@end
