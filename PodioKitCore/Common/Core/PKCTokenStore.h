//
//  PKCTokenStore.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 10/06/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKCOAuth2Token.h"

@protocol PKCTokenStore <NSObject>

- (void)storeToken:(PKCOAuth2Token *)token;

- (void)deleteStoredToken;

- (PKCOAuth2Token *)storedToken;

@end
