//
//  PKCPushClient.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 27/10/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKCPushEvent.h"
#import "PKCPushCredential.h"

typedef void (^PKCPushEventBlock) (PKCPushEvent *event);

@interface PKCPushSubscription : NSObject

- (void)unsubscribe;

@end

@interface PKCPushClient : NSObject

@property (nonatomic, copy) NSURL *endpointURL;

/**
 *  The shared singleton push client.
 *
 *  @return The shared push client.
 */
+ (PKCPushClient *)sharedClient;

/**
 *  Subscribe to a specific channel for a specific set of credentials, retrieved from the domain object to subscribe to.
 *
 *  @param credential The push credential
 *  @param eventBlock The event block to be executed whenever a new event occurs. The event block will be retained 
 *                    by the client, so beware of retain cycles.
 *
 *  @return The subscription.
 */
- (PKCPushSubscription *)subscribeWithCredential:(PKCPushCredential *)credential eventBlock:(PKCPushEventBlock)eventBlock;

/**
 *  Unsubscribe from a subscription.
 *
 *  @see see -subscribeWithCredential:eventBlock:
 *
 *  @param token The subscription to unsubscribe from.
 */
- (void)unsubscribe:(PKCPushSubscription *)subscription;

@end
