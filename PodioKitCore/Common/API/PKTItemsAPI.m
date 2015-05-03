//
//  PKTItemsAPI.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 31/03/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKTItemsAPI.h"

@implementation PKTItemsAPI

+ (PKTRequest *)requestForItemWithID:(NSUInteger)itemID {
  return [PKTRequest GETRequestWithPath:PKTRequestPath(@"/item/%lu", (unsigned long)itemID) parameters:nil];
}

+ (PKTRequest *)requestForItemWithExternalID:(NSUInteger)externalID inAppWithID:(NSUInteger)appID {
  return [PKTRequest GETRequestWithPath:PKTRequestPath(@"/item/app/%lu/external_id/%lu", (unsigned long)appID, (unsigned long)externalID) parameters:nil];
}

+ (PKTRequest *)requestForReferencesForItemWithID:(NSUInteger)itemID {
  NSString *path = PKTRequestPath(@"/item/%lu/reference/", (unsigned long)itemID);
  PKTRequest *request = [PKTRequest GETRequestWithPath:path parameters:nil];
  
  return request;
}

+ (PKTRequest *)requestForFilteredItemsInAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending remember:(BOOL)remember {
  return [self requestForFilteredItemsInAppWithID:appID offset:offset limit:limit sortBy:sortBy descending:descending remember:remember filters:nil];
}

+ (PKTRequest *)requestForFilteredItemsInAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending remember:(BOOL)remember filters:(NSDictionary *)filters {
  return [self requestForFilteredItemsInAppWithID:appID spaceID:0 offset:offset limit:limit sortBy:sortBy descending:descending remember:remember filters:filters];
}

+ (PKTRequest *)requestForFilteredItemsInAppWithID:(NSUInteger)appID spaceID:(NSUInteger)spaceID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending remember:(BOOL)remember filters:(NSDictionary *)filters {
  NSParameterAssert(appID > 0);
  
  NSMutableDictionary *parameters = [NSMutableDictionary new];
  parameters[@"offset"] = @(offset);
  parameters[@"limit"] = @(limit);
  parameters[@"sort_desc"] = @(descending);
  parameters[@"remember"] = @(remember);
  
  if (spaceID > 0) {
    parameters[@"space_id"] = @(spaceID);
  }
  
  if (sortBy) {
    parameters[@"sort_by"] = sortBy;
  }
  
  if (filters) {
    parameters[@"filters"] = filters;
  }
  
  NSString *path = PKTRequestPath(@"/item/app/%lu/filter/", (unsigned long)appID);
  PKTRequest *request = [PKTRequest POSTRequestWithPath:path parameters:parameters];
  
  return request;
}

+ (PKTRequest *)requestForFilteredItemsInAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit viewID:(NSUInteger)viewID remember:(BOOL)remember {
  NSParameterAssert(appID > 0);
  
  NSMutableDictionary *parameters = [NSMutableDictionary new];
  parameters[@"offset"] = @(offset);
  parameters[@"limit"] = @(limit);
  parameters[@"remember"] = @(remember);

  NSString *path = PKTRequestPath(@"/item/app/%lu/filter/%lu/", (unsigned long)appID, (unsigned long)viewID);
  PKTRequest *request = [PKTRequest POSTRequestWithPath:path parameters:parameters];

  return request;
}

+ (PKTRequest *)requestToCreateItemInAppWithID:(NSUInteger)appID fields:(NSDictionary *)fields files:(NSArray *)files tags:(NSArray *)tags {
  return [self requestToCreateItemInAppWithID:appID spaceID:0 fields:fields files:files tags:tags];
}

+ (PKTRequest *)requestToCreateItemInAppWithID:(NSUInteger)appID spaceID:(NSUInteger)spaceID fields:(NSDictionary *)fields files:(NSArray *)files tags:(NSArray *)tags {
  NSMutableDictionary *parameters = [NSMutableDictionary new];
  
  if (spaceID > 0) {
    parameters[@"space_id"] = @(spaceID);
  }
  
  if ([fields count] > 0) {
    parameters[@"fields"] = fields;
  }
  
  if ([files count] > 0) {
    parameters[@"file_ids"] = files;
  }
  
  if ([tags count] > 0) {
    parameters[@"tags"] = tags;
  }
  
  NSString *path = PKTRequestPath(@"/item/app/%lu/", (unsigned long)appID);
  PKTRequest *request = [PKTRequest POSTRequestWithPath:path parameters:parameters];
  
  return request;
}

+ (PKTRequest *)requestToUpdateItemWithID:(NSUInteger)itemID fields:(NSDictionary *)fields files:(NSArray *)files tags:(NSArray *)tags {
  NSMutableDictionary *parameters = [NSMutableDictionary new];
  
  if ([fields count] > 0) {
    parameters[@"fields"] = fields;
  }
  
  if ([files count] > 0) {
    parameters[@"file_ids"] = files;
  }
  
  if ([tags count] > 0) {
    parameters[@"tags"] = tags;
  }
  
  NSString *path = PKTRequestPath(@"/item/%lu", (unsigned long)itemID);
  PKTRequest *request = [PKTRequest PUTRequestWithPath:path parameters:parameters];
  
  return request;
}

@end
