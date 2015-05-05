//
//  PKTItemsAPI.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 31/03/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKTBaseAPI.h"

@interface PKTItemsAPI : PKTBaseAPI

+ (PKTRequest *)requestForItemWithID:(NSUInteger)itemID;

+ (PKTRequest *)requestForItemWithExternalID:(NSUInteger)externalID inAppWithID:(NSUInteger)appID;

+ (PKTRequest *)requestForReferencesForItemWithID:(NSUInteger)itemID;

+ (PKTRequest *)requestForFilteredItemsInAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending remember:(BOOL)remember;

+ (PKTRequest *)requestForFilteredItemsInAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending remember:(BOOL)remember filters:(NSDictionary *)filters;

+ (PKTRequest *)requestForFilteredItemsInAppWithID:(NSUInteger)appID spaceID:(NSUInteger)spaceID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending remember:(BOOL)remember filters:(NSDictionary *)filters;

+ (PKTRequest *)requestForFilteredItemsInAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit viewID:(NSUInteger)viewID remember:(BOOL)remember;

+ (PKTRequest *)requestToCreateItemInPersonalSpaceForAppWithID:(NSUInteger)appID fields:(NSDictionary *)fields files:(NSArray *)files tags:(NSArray *)tags;

+ (PKTRequest *)requestToCreateItemInPublicSpaceForAppWithID:(NSUInteger)appID fields:(NSDictionary *)fields files:(NSArray *)files tags:(NSArray *)tags;

+ (PKTRequest *)requestToCreateItemInAppWithID:(NSUInteger)appID fields:(NSDictionary *)fields files:(NSArray *)files tags:(NSArray *)tags;

+ (PKTRequest *)requestToCreateItemInAppWithID:(NSUInteger)appID spaceID:(NSUInteger)spaceID fields:(NSDictionary *)fields files:(NSArray *)files tags:(NSArray *)tags;

+ (PKTRequest *)requestToUpdateItemWithID:(NSUInteger)itemID fields:(NSDictionary *)fields files:(NSArray *)files tags:(NSArray *)tags;

@end
