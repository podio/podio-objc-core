//
//  PKCReferenceTypeValueTransformer.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 22/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCReferenceTypeValueTransformer.h"
#import "PKCConstants.h"

@implementation PKCReferenceTypeValueTransformer

- (instancetype)init {
  return [super initWithDictionary:@{
    @"app" : @(PKCReferenceTypeApp),
    @"app_revision" : @(PKCReferenceTypeAppRevision),
    @"app_field" : @(PKCReferenceTypeAppField),
    @"item" : @(PKCReferenceTypeItem),
    @"bulletin" : @(PKCReferenceTypeBulletin),
    @"comment" : @(PKCReferenceTypeComment),
    @"status" : @(PKCReferenceTypeStatus),
    @"space_member" : @(PKCReferenceTypeSpaceMember),
    @"alert" : @(PKCReferenceTypeAlert),
    @"item_revision" : @(PKCReferenceTypeItemRevision),
    @"rating" : @(PKCReferenceTypeRating),
    @"task" : @(PKCReferenceTypeTask),
    @"task_action" : @(PKCReferenceTypeTaskAction),
    @"space" : @(PKCReferenceTypeSpace),
    @"org" : @(PKCReferenceTypeOrg),
    @"conversation" : @(PKCReferenceTypeConversation),
    @"message" : @(PKCReferenceTypeMessage),
    @"notification" : @(PKCReferenceTypeNotification),
    @"file" : @(PKCReferenceTypeFile),
    @"file_service" : @(PKCReferenceTypeFileService),
    @"profile" : @(PKCReferenceTypeProfile),
    @"user" : @(PKCReferenceTypeUser),
    @"widget" : @(PKCReferenceTypeWidget),
    @"share" : @(PKCReferenceTypeShare),
    @"form" : @(PKCReferenceTypeForm),
    @"auth_client" : @(PKCReferenceTypeAuthClient),
    @"connection" : @(PKCReferenceTypeConnection),
    @"integration" : @(PKCReferenceTypeIntegration),
    @"share_install" : @(PKCReferenceTypeShareInstall),
    @"icon" : @(PKCReferenceTypeIcon),
    @"org_member" : @(PKCReferenceTypeOrgMember),
    @"news" : @(PKCReferenceTypeNews),
    @"hook" : @(PKCReferenceTypeHook),
    @"tag" : @(PKCReferenceTypeTag),
    @"embed" : @(PKCReferenceTypeEmbed),
    @"question" : @(PKCReferenceTypeQuestion),
    @"question_answer" : @(PKCReferenceTypeQuestionAnswer),
    @"action" : @(PKCReferenceTypeAction),
    @"contract" : @(PKCReferenceTypeContract),
    @"meeting" : @(PKCReferenceTypeMeeting),
    @"batch" : @(PKCReferenceTypeBatch),
    @"system" : @(PKCReferenceTypeSystem),
    @"space_member_request" : @(PKCReferenceTypeSpaceMemberRequest),
    @"live" : @(PKCReferenceTypeLive),
    @"item_participation" : @(PKCReferenceTypeItemParticipation),
  }];
}

@end
