//
//  PKCPushEvent.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 27/10/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCModel.h"
#import "PKCConstants.h"

typedef NS_ENUM(NSUInteger, PKCPushEventType) {
  PKCPushEventTypeUnknown,
  
  PKCPushEventTypeTyping,
  PKCPushEventTypeViewing,
  PKCPushEventTypeLeaving,
  
  PKCPushEventTypeCommentCreate,
  PKCPushEventTypeCommentUpdate,
  PKCPushEventTypeCommentDelete,
  
  PKCPushEventTypeConversationStarredCount,
  PKCPushEventTypeConversationUnreadCount,
  PKCPushEventTypeConversationRead,
  PKCPushEventTypeConversationUnread,
  PKCPushEventTypeConversationStarred,
  PKCPushEventTypeConversationUnstarred,
  PKCPushEventTypeConversationReadAll,
  PKCPushEventTypeConversationEvent,
  
  PKCPushEventTypeFileAttach,
  PKCPushEventTypeFileDelete,
  
  PKCPushEventTypeCreate,
  PKCPushEventTypeUpdate,
  PKCPushEventTypeDelete,
  
  PKCPushEventTypeRatingLikeCreate,
  PKCPushEventTypeRatingLikeDelete,
  
  PKCPushEventTypeStreamCreate,
  
  PKCPushEventTypeSubscribe,
  PKCPushEventTypeUnsubscribe,
  
  PKCPushEventTypeNotificationUnread,
  PKCPushEventTypeNotificationCreate,
};

@interface PKCPushEvent : PKCModel

@property (nonatomic, copy, readonly) NSString *channel;
@property (nonatomic, readonly) PKCPushEventType eventType;
@property (nonatomic, readonly) PKCReferenceType referenceType;
@property (nonatomic, readonly) NSUInteger referenceID;
@property (nonatomic, readonly) NSUInteger createdByID;
@property (nonatomic, readonly) PKCReferenceType createdByType;
@property (nonatomic, strong, readonly) id data;

@end
