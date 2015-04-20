//
//  PKCPushEvent.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 27/10/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCPushEvent.h"
#import "NSValueTransformer+PKCTransformers.h"
#import "NSValueTransformer+PKCConstants.h"

@implementation PKCPushEvent

#pragma mark - PKCModel

+ (NSDictionary *)dictionaryKeyPathsForPropertyNames {
  return @{
           @"eventType" : @"data.event",
           @"referenceID" : @"data.ref.id",
           @"referenceType" : @"data.ref.type",
           @"createdByType" : @"data.created_by.type",
           @"createdByID" : @"data.created_by.id",
           @"data" : @"data.data"
          };
}

+ (NSValueTransformer *)eventTypeValueTransformer {
  static NSDictionary *eventTypes;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    eventTypes = @{
                   @"typing": @(PKCPushEventTypeTyping),
                   @"viewing": @(PKCPushEventTypeViewing),
                   @"leaving": @(PKCPushEventTypeLeaving),
                   @"conversation_event": @(PKCPushEventTypeConversationEvent),
                   @"conversation_read": @(PKCPushEventTypeConversationRead),
                   @"conversation_unread": @(PKCPushEventTypeConversationUnread),
                   @"conversation_starred": @(PKCPushEventTypeConversationStarred),
                   @"conversation_unstarred": @(PKCPushEventTypeConversationUnstarred),
                   @"conversation_read_all": @(PKCPushEventTypeConversationReadAll),
                   @"conversation_starred_count": @(PKCPushEventTypeConversationStarredCount),
                   @"conversation_unread_count": @(PKCPushEventTypeConversationUnreadCount),
                   @"notification_unread": @(PKCPushEventTypeNotificationUnread),
                   @"notification_create": @(PKCPushEventTypeNotificationCreate),
                   };
  });
  
  return [NSValueTransformer pkc_transformerWithDictionary:eventTypes];
}

+ (NSValueTransformer *)referenceTypeValueTransformer {
  return [NSValueTransformer pkc_referenceTypeTransformer];
}

+ (NSValueTransformer *)createdByTypeValueTransformer {
  return [NSValueTransformer pkc_referenceTypeTransformer];
}

@end
