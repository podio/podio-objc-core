//
//  PKSessionManager+Test.h
//  PodioKit
//
//  Created by Romain Briche on 30/01/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCClient.h"

@interface PKCClient (Test)

- (PKCAsyncTask *)refreshToken;

@end
