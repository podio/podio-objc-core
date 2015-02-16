//
//  PKCReferenceTypeValueTransformerTests.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 22/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCConstants.h"
#import "PKCReferenceTypeValueTransformer.h"

@interface PKCReferenceTypeValueTransformerTests : XCTestCase

@end

@implementation PKCReferenceTypeValueTransformerTests

- (void)testReferenceTypesValueTransformation {
  PKCReferenceTypeValueTransformer *transformer = [PKCReferenceTypeValueTransformer new];
  expect([transformer transformedValue:@"app"]).to.equal(PKCReferenceTypeApp);
  expect([transformer transformedValue:@"app_revision"]).to.equal(PKCReferenceTypeAppRevision);
  expect([transformer transformedValue:@"app_field"]).to.equal(PKCReferenceTypeAppField);
  expect([transformer transformedValue:@"item"]).to.equal(PKCReferenceTypeItem);
  expect([transformer transformedValue:@"bulletin"]).to.equal(PKCReferenceTypeBulletin);
  expect([transformer transformedValue:@"comment"]).to.equal(PKCReferenceTypeComment);
  expect([transformer transformedValue:@"status"]).to.equal(PKCReferenceTypeStatus);
  expect([transformer transformedValue:@"space_member"]).to.equal(PKCReferenceTypeSpaceMember);
  expect([transformer transformedValue:@"alert"]).to.equal(PKCReferenceTypeAlert);
  expect([transformer transformedValue:@"item_revision"]).to.equal(PKCReferenceTypeItemRevision);
  expect([transformer transformedValue:@"rating"]).to.equal(PKCReferenceTypeRating);
  expect([transformer transformedValue:@"task"]).to.equal(PKCReferenceTypeTask);
  expect([transformer transformedValue:@"task_action"]).to.equal(PKCReferenceTypeTaskAction);
  expect([transformer transformedValue:@"space"]).to.equal(PKCReferenceTypeSpace);
  expect([transformer transformedValue:@"org"]).to.equal(PKCReferenceTypeOrg);
  expect([transformer transformedValue:@"conversation"]).to.equal(PKCReferenceTypeConversation);
  expect([transformer transformedValue:@"message"]).to.equal(PKCReferenceTypeMessage);
  expect([transformer transformedValue:@"notification"]).to.equal(PKCReferenceTypeNotification);
  expect([transformer transformedValue:@"file"]).to.equal(PKCReferenceTypeFile);
  expect([transformer transformedValue:@"file_service"]).to.equal(PKCReferenceTypeFileService);
  expect([transformer transformedValue:@"profile"]).to.equal(PKCReferenceTypeProfile);
  expect([transformer transformedValue:@"user"]).to.equal(PKCReferenceTypeUser);
  expect([transformer transformedValue:@"widget"]).to.equal(PKCReferenceTypeWidget);
  expect([transformer transformedValue:@"share"]).to.equal(PKCReferenceTypeShare);
  expect([transformer transformedValue:@"form"]).to.equal(PKCReferenceTypeForm);
  expect([transformer transformedValue:@"auth_client"]).to.equal(PKCReferenceTypeAuthClient);
  expect([transformer transformedValue:@"connection"]).to.equal(PKCReferenceTypeConnection);
  expect([transformer transformedValue:@"integration"]).to.equal(PKCReferenceTypeIntegration);
  expect([transformer transformedValue:@"share_install"]).to.equal(PKCReferenceTypeShareInstall);
  expect([transformer transformedValue:@"icon"]).to.equal(PKCReferenceTypeIcon);
  expect([transformer transformedValue:@"org_member"]).to.equal(PKCReferenceTypeOrgMember);
  expect([transformer transformedValue:@"news"]).to.equal(PKCReferenceTypeNews);
  expect([transformer transformedValue:@"hook"]).to.equal(PKCReferenceTypeHook);
  expect([transformer transformedValue:@"tag"]).to.equal(PKCReferenceTypeTag);
  expect([transformer transformedValue:@"embed"]).to.equal(PKCReferenceTypeEmbed);
  expect([transformer transformedValue:@"question"]).to.equal(PKCReferenceTypeQuestion);
  expect([transformer transformedValue:@"question_answer"]).to.equal(PKCReferenceTypeQuestionAnswer);
  expect([transformer transformedValue:@"action"]).to.equal(PKCReferenceTypeAction);
  expect([transformer transformedValue:@"contract"]).to.equal(PKCReferenceTypeContract);
  expect([transformer transformedValue:@"meeting"]).to.equal(PKCReferenceTypeMeeting);
  expect([transformer transformedValue:@"batch"]).to.equal(PKCReferenceTypeBatch);
  expect([transformer transformedValue:@"system"]).to.equal(PKCReferenceTypeSystem);
  expect([transformer transformedValue:@"space_member_request"]).to.equal(PKCReferenceTypeSpaceMemberRequest);
  expect([transformer transformedValue:@"live"]).to.equal(PKCReferenceTypeLive);
  expect([transformer transformedValue:@"item_participation"]).to.equal(PKCReferenceTypeItemParticipation);
}

@end
