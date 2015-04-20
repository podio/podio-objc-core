//
//  PKCPushClient.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 27/10/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <DDCometClient/DDCometClient.h>
#import <DDCometClient/DDCometSubscription.h>
#import <DDCometClient/DDCometMessage.h>
#import <FXReachability/FXReachability.h>
#import "PKCPushClient.h"
#import "PKCMacros.h"
#import "NSSet+PKCAdditions.h"

#pragma mark - PKCPushClient

typedef NS_ENUM(NSUInteger, PKCPushSubscriptionState) {
  PKCPushSubscriptionStateInactive,
  PKCPushSubscriptionStateSubscribing,
  PKCPushSubscriptionStateActive
};

@interface PKCInternalPushSubscription : NSObject

@property (nonatomic, copy, readonly) NSString *channel;
@property (nonatomic, copy, readonly) NSDictionary *extensions;
@property (nonatomic, copy, readonly) PKCPushEventBlock eventBlock;
@property (nonatomic) PKCPushSubscriptionState state;
@property (nonatomic, weak, readonly) PKCPushClient *client;

@end

#pragma mark - PKCInternalPushSubscription

@implementation PKCInternalPushSubscription

- (instancetype)initWithChannel:(NSString *)channel extensions:(NSDictionary *)extensions client:(PKCPushClient *)client eventBlock:(PKCPushEventBlock)eventBlock {
  NSParameterAssert(eventBlock);
  
  self = [super init];
  if (!self) return nil;
  
  _channel = [channel copy];
  _extensions = [extensions copy];
  _eventBlock = [eventBlock copy];
  _state = PKCPushSubscriptionStateInactive;
  _client = client;
  
  return self;
}

- (void)deliverMessage:(DDCometMessage *)message {
  PKCPushEvent *event = [[PKCPushEvent alloc] initWithDictionary:message.data];
  self.eventBlock(event);
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other {
  if (other == self) {
    return YES;
  } else if (![super isEqual:other]) {
    return NO;
  } else if (![other isKindOfClass:[self class]]) {
    return NO;
  } else {
    return [self.channel isEqualToString:[(PKCInternalPushSubscription *)other channel]];
  }
}

- (NSUInteger)hash {
  return [self.channel hash];
}

@end

#pragma mark - PKCPushSubscription

@interface PKCPushSubscription ()

@property (nonatomic, strong, readonly) PKCInternalPushSubscription *internalSubscription;

@end

@implementation PKCPushSubscription

- (instancetype)initWithInternalSubscription:(PKCInternalPushSubscription *)subscription {
  self = [super init];
  if (!self) return nil;
  
  _internalSubscription = subscription;
  
  return self;
}

- (void)dealloc {
  [_internalSubscription.client unsubscribe:self];
}

+ (instancetype)subscriptionForInternalSubscription:(PKCInternalPushSubscription *)subscription {
  return [[self alloc] initWithInternalSubscription:subscription];
}

- (void)unsubscribe {
  [self.internalSubscription.client unsubscribe:self];
}

@end

#pragma mark - PKCPushClient

static NSString * const kDefaultEndpointURLString = @"https://push.podio.com/faye";

@interface PKCPushClient () <DDCometClientDelegate>

@property (nonatomic, strong) DDCometClient *client;
@property (nonatomic, strong) FXReachability *reachability;
//@property (nonatomic, strong) Reachability *reachability;

@property (nonatomic, readonly, getter=isDisonnected) BOOL disconnected;
@property (nonatomic, readonly, getter=isConnecting) BOOL connecting;
@property (nonatomic, readonly, getter=isConnected) BOOL connected;
@property (nonatomic, readonly, getter=isDisconnecting) BOOL disconnecting;

@property (nonatomic, strong) NSMutableSet *subscriptions;
@property (nonatomic, copy) NSSet *inactiveSubscriptions;
@property (nonatomic, copy) NSSet *activeSubscriptions;
@property (nonatomic, copy) NSSet *subscribingSubscriptions;

@end

@implementation PKCPushClient

+ (PKCPushClient *)sharedClient {
  static id sharedClient;
  static dispatch_once_t once;
  
  dispatch_once(&once, ^{
    sharedClient = [[self alloc] initWithEndpointURL:[NSURL URLWithString:kDefaultEndpointURLString]];
  });
  
  return sharedClient;
}

- (instancetype)initWithEndpointURL:(NSURL *)url {
  NSParameterAssert(url);
  
  self = [super init];
  if (!self) return nil;
  
  _endpointURL = [url copy];
  _subscriptions = [NSMutableSet new];

  [self setupClientForCurrentEndpointURL];
  
  return self;
}

- (void)dealloc {
  if (_reachability) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FXReachabilityStatusDidChangeNotification
                                                  object:_reachability];
  }
}

#pragma mark - Properties

- (void)setEndpointURL:(NSURL *)endpointURL {
  _endpointURL = [endpointURL copy];
  [self setupClientForCurrentEndpointURL];
}

- (BOOL)isDisconnected {
  return self.client.state == DDCometStateDisconnected;
}

- (BOOL)isConnecting {
  return self.client.state == DDCometStateConnecting;
}

- (BOOL)isConnected {
  return self.client.state == DDCometStateConnected;
}

- (BOOL)isDisconnecting {
  return self.client.state == DDCometStateDisconnecting;
}

- (NSSet *)inactiveSubscriptions {
  return [self.subscriptions pkc_filteredSetWithBlock:^BOOL(PKCInternalPushSubscription *subscription) {
    return subscription.state == PKCPushSubscriptionStateInactive;
  }];
}

- (NSSet *)activeSubscriptions {
  return [self.subscriptions pkc_filteredSetWithBlock:^BOOL(PKCInternalPushSubscription *subscription) {
    return subscription.state == PKCPushSubscriptionStateActive;
  }];
}

- (NSSet *)subscribingSubscriptions {
  return [self.subscriptions pkc_filteredSetWithBlock:^BOOL(PKCInternalPushSubscription *subscription) {
    return subscription.state == PKCPushSubscriptionStateSubscribing;
  }];
}

#pragma mark - Private

- (void)setupClientForCurrentEndpointURL {
  if (!self.endpointURL || [self.client.endpointURL isEqual:self.endpointURL]) return;
  
  _client = [[DDCometClient alloc] initWithURL:self.endpointURL];
  _client.delegate = self;
  
  if (_reachability) {
    // We need to unsubscribe from the old reachability object
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FXReachabilityStatusDidChangeNotification
                                                  object:_reachability];
  }
  
  _reachability = [[FXReachability alloc] initWithHost:[self.endpointURL host]];
  
  // Observe reachability changes to new endpoint URL
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(reachabilityChanged:)
                                               name:FXReachabilityStatusDidChangeNotification
                                             object:_reachability];
}

- (void)connect {
  if (self.isConnected || self.isConnecting) {
    return;
  }

  [self.client scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [self.client handshake];
}

- (void)disconnect {
  if (self.isDisonnected || self.isDisconnecting) {
    return;
  }
  
  [self unsubscribeAllSubscriptions];

  [self.client disconnect];
}

- (void)addSubscription:(PKCInternalPushSubscription *)subscription {
  NSParameterAssert(subscription);
  [self.subscriptions addObject:subscription];
  [self subscriptionsDidChange];
}

- (void)removeSubscription:(PKCInternalPushSubscription *)subscription {
  NSParameterAssert(subscription);
  [self.subscriptions removeObject:subscription];
  [self subscriptionsDidChange];
}

- (void)resubscribeToInactiveSubscriptionsIfAny {
  if (!self.connected && !self.connecting) return;
  
  for (PKCInternalPushSubscription *subscription in self.inactiveSubscriptions) {
    subscription.state = PKCPushSubscriptionStateSubscribing;
    [self.client subscribeToChannel:subscription.channel
                         extensions:subscription.extensions
                             target:subscription
                           selector:@selector(deliverMessage:)];
  }
}

- (void)activateSubscriptionForChannel:(NSString *)channel {
  for (PKCInternalPushSubscription *subscription in self.subscribingSubscriptions) {
    if ([subscription.channel isEqualToString:channel]) {
      subscription.state = PKCPushSubscriptionStateActive;
    }
  }
}

- (void)deactivateSubscriptionForChannel:(NSString *)channel {
  for (PKCInternalPushSubscription *subscription in self.subscribingSubscriptions) {
    if ([subscription.channel isEqualToString:channel]) {
      subscription.state = PKCPushSubscriptionStateInactive;
    }
  }
}

- (void)subscriptionsDidChange {
  if (!self.connected && !self.connecting) {
    // If not connected, we need to attempt to connect before subscribing. The subscription step for inactive
    // subscriptions will happen automatically after the client has been successfully connected.
    [self updateConnectionForCurrentState];
  } else if (self.connected) {
    // If connected, check if there are any inactive subscriptions that needs to subscribe to.
    // e.g. if a new subscription was added.
    [self resubscribeToInactiveSubscriptionsIfAny];
  }
}

- (void)unsubscribeAllSubscriptions {
  for (PKCInternalPushSubscription *subscription in self.activeSubscriptions) {
    subscription.state = PKCPushSubscriptionStateInactive;
    [self.client unsubsubscribeFromChannel:subscription.channel target:subscription selector:@selector(deliverMessage:)];
  }
}

- (void)updateConnectionForCurrentState {
  // There is only a reason to maintain a connection to the server if there are any
  // subscriptions and if the host is reachable. Otherwise we disconnect the client.
  if (self.reachability.isReachable && self.subscriptions > 0) {
    [self connect];
  } else {
    [self disconnect];
  }
}

+ (NSDictionary *)extensionsForCredential:(PKCPushCredential *)credential {
  NSParameterAssert(credential);
  
  return @{ @"private_pub_timestamp": credential.timestamp,
            @"private_pub_signature": credential.signature };
}

#pragma mark - Public

- (id)subscribeWithCredential:(PKCPushCredential *)credential eventBlock:(PKCPushEventBlock)block {
  NSDictionary *extensions = [[self class] extensionsForCredential:credential];
  PKCInternalPushSubscription *subscription = [[PKCInternalPushSubscription alloc] initWithChannel:credential.channel
                                                                                        extensions:extensions
                                                                                            client:self
                                                                                        eventBlock:block];
  [self addSubscription:subscription];
  
  return [PKCPushSubscription subscriptionForInternalSubscription:subscription];
}

- (void)unsubscribe:(PKCPushSubscription *)subscription {
  PKCInternalPushSubscription *internalSubscription = subscription.internalSubscription;
  
  if (internalSubscription) {
    [self removeSubscription:internalSubscription];
    [self.client unsubsubscribeFromChannel:internalSubscription.channel
                                    target:internalSubscription
                                  selector:@selector(deliverMessage:)];
  }
}

#pragma mark - DDCometClientDelegate

- (void)cometClientHandshakeDidSucceed:(DDCometClient *)client {
  [self resubscribeToInactiveSubscriptionsIfAny];
}

- (void)cometClientConnectDidSucceed:(DDCometClient *)client {
  [self resubscribeToInactiveSubscriptionsIfAny];
}

- (void)cometClient:(DDCometClient *)client subscriptionDidSucceed:(DDCometSubscription *)subscription {
  [self activateSubscriptionForChannel:subscription.channel];
}

- (void)cometClient:(DDCometClient *)client subscription:(DDCometSubscription *)subscription didFailWithError:(NSError *)error {
  [self deactivateSubscriptionForChannel:subscription.channel];
}

#pragma mark - Notifications

- (void)reachabilityChanged:(NSNotification *)notification {
  [self updateConnectionForCurrentState];
}

@end
