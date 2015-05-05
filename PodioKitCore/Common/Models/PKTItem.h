//
//  PKTItem.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 31/03/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKTModel.h"
#import "PKTClient.h"

@class PKTFile;
@class PKTByLine;
@class PKTApp;

typedef void(^PKTItemFilteredFetchCompletionBlock)(NSArray *items, NSUInteger filteredCount, NSUInteger totalCount, NSError *error);

@interface PKTItem : PKTModel

@property (nonatomic, assign, readonly) NSUInteger itemID;
@property (nonatomic, assign, readonly) NSUInteger externalID;
@property (nonatomic, assign, readonly) NSUInteger appID;
@property (nonatomic, assign, readonly) NSUInteger appItemID;
@property (nonatomic, strong, readonly) NSDate *createdOn;
@property (nonatomic, strong, readonly) PKTByLine *createdBy;
@property (nonatomic, strong, readonly) PKTApp *app;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSArray *fields;
@property (nonatomic, copy, readonly) NSArray *files;
@property (nonatomic, copy, readonly) NSArray *comments;
@property (nonatomic, copy, readonly) NSURL *link;

- (instancetype)initWithAppID:(NSUInteger)appID;

- (instancetype)initWithTemplateID:(NSUInteger)templateID;

+ (instancetype)itemForAppWithID:(NSUInteger)appID;

+ (instancetype)itemUsingTemplateWithID:(NSUInteger)templateID;

#pragma mark - API

+ (PKTAsyncTask *)fetchItemWithID:(NSUInteger)itemID;

+ (PKTAsyncTask *)fetchItemWithExternalID:(NSUInteger)externalID inAppWithID:(NSUInteger)appID;

+ (PKTAsyncTask *)fetchReferencesForItemWithID:(NSUInteger)itemID;

+ (PKTAsyncTask *)fetchItemsInAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit;

+ (PKTAsyncTask *)fetchItemsInAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending;

+ (PKTAsyncTask *)fetchItemsInAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending filters:(NSDictionary *)filters;

+ (PKTAsyncTask *)fetchItemsInAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit viewID:(NSUInteger)viewID;

+ (PKTAsyncTask *)fetchItemsInPersonalSpaceForAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending filters:(NSDictionary *)filters;

+ (PKTAsyncTask *)fetchItemsInPublicSpaceForAppWithID:(NSUInteger)appID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending filters:(NSDictionary *)filters;

+ (PKTAsyncTask *)fetchItemsInAppWithID:(NSUInteger)appID spaceID:(NSUInteger)spaceID offset:(NSUInteger)offset limit:(NSUInteger)limit sortBy:(NSString *)sortBy descending:(BOOL)descending filters:(NSDictionary *)filters;

- (PKTAsyncTask *)createInSpaceWithID:(NSUInteger)spaceID;

- (PKTAsyncTask *)createInPersonalSpace;

- (PKTAsyncTask *)createInPublicSpace;

- (PKTAsyncTask *)fetch;

- (PKTAsyncTask *)save;

#pragma mark - Public

- (NSArray *)valuesForField:(NSString *)externalID;
- (void)setValues:(NSArray *)values forField:(NSString *)externalID;

- (id)valueForField:(NSString *)externalID;
- (void)setValue:(id)value forField:(NSString *)externalID;

- (void)addValue:(id)value forField:(NSString *)externalID;

- (void)removeValue:(id)value forField:(NSString *)externalID;
- (void)removeValueAtIndex:(NSUInteger)index forField:(NSString *)externalID;

- (void)addFile:(PKTFile *)file;
- (void)removeFileWithID:(NSUInteger)filefileID;

#pragma mark - Subscripting for item fields

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
