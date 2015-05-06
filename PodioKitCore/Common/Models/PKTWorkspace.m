//
//  PKTWorkspace.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 12/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKTWorkspace.h"
#import "PKTByLine.h"
#import "PKTWorkspacesAPI.h"
#import "PKTWorkspaceMembersAPI.h"
#import "PKTClient.h"
#import "NSValueTransformer+PKTTransformers.h"

@implementation PKTWorkspace

#pragma mark - PKTModel

+ (NSDictionary *)dictionaryKeyPathsForPropertyNames {
  return @{
           @"spaceID" : @"space_id",
           @"organizationID" : @"org_id",
           @"linkURL" : @"url",
           @"descriptionText" : @"description",
           @"createdOn" : @"created_on",
           @"createdBy" : @"created_by",
           @"spaceType" : @"type",
           };
}

+ (NSValueTransformer *)linkURLValueTransformer {
  return [NSValueTransformer pkt_URLTransformer];
}

+ (NSValueTransformer *)createdOnValueTransformer {
  return [NSValueTransformer pkt_dateValueTransformer];
}

+ (NSValueTransformer *)createdByValueTransformer {
  return [NSValueTransformer pkt_transformerWithModelClass:[PKTByLine class]];
}

+ (NSValueTransformer *)roleValueTransformer {
  return [NSValueTransformer pkt_transformerWithDictionary:@{@"regular" : @(PKTWorkspaceMemberRoleRegular),
                                                             @"admin" : @(PKTWorkspaceMemberRoleAdmin),
                                                             @"light" : @(PKTWorkspaceMemberRoleLight)}];
}

+ (NSValueTransformer *)spaceTypeValueTransformer {
  return [NSValueTransformer pkt_transformerWithDictionary:@{@"regular" : @(PKTWorkspaceTypeRegular),
                                                             @"emp_network" : @(PKTWorkspaceTypeEmployeeNetwork),
                                                             @"demo" : @(PKTWorkspaceTypeDemo)}];
}

#pragma mark - Public

+ (PKTAsyncTask *)fetchWorkspaceWithID:(NSUInteger)workspaceID {
  PKTRequest *request = [PKTWorkspacesAPI requestForWorkspaceWithID:workspaceID];
  PKTAsyncTask *task = [[PKTClient currentClient] performRequest:request];
  
  return [task map:^id(PKTResponse *response) {
    return [[self alloc] initWithDictionary:response.body];
  }];
}

+ (PKTAsyncTask *)fetchWorkspaceWithURLString:(NSString *)urlString {
  PKTRequest *request = [PKTWorkspacesAPI requestForWorkspaceWithURLString:urlString];
  PKTAsyncTask *task = [[PKTClient currentClient] performRequest:request];
  
  return [task map:^id(PKTResponse *response) {
    return [[self alloc] initWithDictionary:response.body];
  }];
}

+ (PKTAsyncTask *)createWorkspaceWithName:(NSString *)name organizationID:(NSUInteger)organizationID {
  return [self createWorkspaceWithName:name organizationID:organizationID privacy:PKTWorkspacePrivacyUnknown];
}

+ (PKTAsyncTask *)createOpenWorkspaceWithName:(NSString *)name organizationID:(NSUInteger)organizationID {
  return [self createWorkspaceWithName:name organizationID:organizationID privacy:PKTWorkspacePrivacyOpen];
}

+ (PKTAsyncTask *)createPrivateWorkspaceWithName:(NSString *)name organizationID:(NSUInteger)organizationID {
  return [self createWorkspaceWithName:name organizationID:organizationID privacy:PKTWorkspacePrivacyClosed];
}

+ (PKTAsyncTask *)addMemberToSpaceWithID:(NSUInteger)spaceID userID:(NSUInteger)userID role:(PKTWorkspaceMemberRole)role {
  return [self addMembersToSpaceWithID:spaceID userIDs:@[@(userID)] role:role];
}

+ (PKTAsyncTask *)addMemberToSpaceWithID:(NSUInteger)spaceID profileID:(NSUInteger)profileID role:(PKTWorkspaceMemberRole)role {
  return [self addMembersToSpaceWithID:spaceID profileIDs:@[@(profileID)] role:role];
}

+ (PKTAsyncTask *)addMemberToSpaceWithID:(NSUInteger)spaceID email:(NSString *)email role:(PKTWorkspaceMemberRole)role {
  return [self addMembersToSpaceWithID:spaceID emails:@[email] role:role];
}

+ (PKTAsyncTask *)addMembersToSpaceWithID:(NSUInteger)spaceID userIDs:(NSArray *)userIDs role:(PKTWorkspaceMemberRole)role {
  NSParameterAssert([userIDs count] > 0);
  
  return [self addMembersToSpaceWithID:spaceID message:nil role:role userIDs:userIDs profileIDs:nil emails:nil];
}

+ (PKTAsyncTask *)addMembersToSpaceWithID:(NSUInteger)spaceID profileIDs:(NSArray *)profileIDs role:(PKTWorkspaceMemberRole)role {
  NSParameterAssert([profileIDs count] > 0);
  
  return [self addMembersToSpaceWithID:spaceID message:nil role:role userIDs:nil profileIDs:profileIDs emails:nil];
}

+ (PKTAsyncTask *)addMembersToSpaceWithID:(NSUInteger)spaceID emails:(NSArray *)emails role:(PKTWorkspaceMemberRole)role {
  NSParameterAssert([emails count] > 0);
  
  return [self addMembersToSpaceWithID:spaceID message:nil role:role userIDs:nil profileIDs:nil emails:emails];
}

#pragma mark - Private

+ (PKTAsyncTask *)createWorkspaceWithName:(NSString *)name organizationID:(NSUInteger)organizationID privacy:(PKTWorkspacePrivacy)privacy {
  PKTRequest *request = [PKTWorkspacesAPI requestToCreateWorkspaceWithName:name organizationID:organizationID privacy:privacy];
  
  PKTAsyncTask *requestTask = [[PKTClient currentClient] performRequest:request];
  
  return [requestTask map:^id(PKTResponse *response) {
    NSMutableDictionary *dict = [response.body mutableCopy];
    dict[@"name"] = name;
    dict[@"org_id"] = @(organizationID);
    
    return [[self alloc] initWithDictionary:dict];
  }];
}

+ (PKTAsyncTask *)addMembersToSpaceWithID:(NSUInteger)spaceID message:(NSString *)message role:(PKTWorkspaceMemberRole)role userIDs:(NSArray *)userIDs profileIDs:(NSArray *)profileIDs emails:(NSArray *)emails {
  PKTRequest *request = [PKTWorkspaceMembersAPI requestToAddMembersToSpaceWithID:spaceID role:role message:message userIDs:userIDs profileIDs:profileIDs emails:emails];
  PKTAsyncTask *task = [[PKTClient currentClient] performRequest:request];
  
  return task;
}

@end
