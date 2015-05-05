//
//  PKTItemAPITests.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 01/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKTItemsAPI.h"

@interface PKTItemAPITests : XCTestCase

@end

@implementation PKTItemAPITests

- (void)testRequestToCreateItemInAppWithID {
  PKTRequest *request = [PKTItemsAPI requestToCreateItemInAppWithID:111
                                                             fields:@{@"title" : @"Some title"}
                                                              files:@[@1234]
                                                               tags:@[@"tag1", @"tag2"]];
  
  expect(request.path).to.equal(@"/item/app/111/");
  expect(request.method).to.equal(PKTRequestMethodPOST);
  expect(request.parameters[@"space_id"]).to.beNil();
  expect(request.parameters[@"fields"]).to.equal(@{@"title" : @"Some title"});
  expect(request.parameters[@"file_ids"]).to.equal(@[@1234]);
  expect(request.parameters[@"tags"]).to.equal(@[@"tag1", @"tag2"]);
}

- (void)testRequestToCreateItemInAppAndSpaceWithID {
  PKTRequest *request = [PKTItemsAPI requestToCreateItemInAppWithID:111
                                                            spaceID:222
                                                             fields:@{@"title" : @"Some title"}
                                                              files:@[@1234]
                                                               tags:@[@"tag1", @"tag2"]];
  
  expect(request.path).to.equal(@"/item/app/111/");
  expect(request.method).to.equal(PKTRequestMethodPOST);
  expect(request.parameters[@"space_id"]).to.equal(@222);
  expect(request.parameters[@"fields"]).to.equal(@{@"title" : @"Some title"});
  expect(request.parameters[@"file_ids"]).to.equal(@[@1234]);
  expect(request.parameters[@"tags"]).to.equal(@[@"tag1", @"tag2"]);
}

- (void)testRequestToCreateItemInPersonalSpace {
  PKTRequest *request = [PKTItemsAPI requestToCreateItemInPersonalSpaceForAppWithID:111
                                                                             fields:@{@"title" : @"Some title"}
                                                                              files:@[@1234]
                                                                               tags:@[@"tag1", @"tag2"]];
  
  expect(request.path).to.equal(@"/item/app/111/personal");
  expect(request.method).to.equal(PKTRequestMethodPOST);
  expect(request.parameters[@"fields"]).to.equal(@{@"title" : @"Some title"});
  expect(request.parameters[@"file_ids"]).to.equal(@[@1234]);
  expect(request.parameters[@"tags"]).to.equal(@[@"tag1", @"tag2"]);
}

- (void)testRequestToCreateItemInPublicSpace {
  PKTRequest *request = [PKTItemsAPI requestToCreateItemInPublicSpaceForAppWithID:111
                                                                           fields:@{@"title" : @"Some title"}
                                                                            files:@[@1234]
                                                                             tags:@[@"tag1", @"tag2"]];
  
  expect(request.path).to.equal(@"/item/app/111/public");
  expect(request.method).to.equal(PKTRequestMethodPOST);
  expect(request.parameters[@"fields"]).to.equal(@{@"title" : @"Some title"});
  expect(request.parameters[@"file_ids"]).to.equal(@[@1234]);
  expect(request.parameters[@"tags"]).to.equal(@[@"tag1", @"tag2"]);
}

- (void)testRequestToUpdateItem {
  NSDictionary *fields = @{
                           @"text": @"Some text",
                           @"number_field": @123,
                           };
  NSArray *files = @[@233, @432];
  NSArray *tags = @[@"tag1", @"tag2"];
  
  PKTRequest *request = [PKTItemsAPI requestToUpdateItemWithID:333 fields:fields files:files tags:tags];
  
  expect(request.path).to.equal(@"/item/333");
  expect(request.parameters[@"fields"]).to.equal([fields copy]);
  expect(request.parameters[@"file_ids"]).to.equal(files);
  expect(request.parameters[@"tags"]).to.equal(tags);
}

- (void)testRequestToGetItem {
  PKTRequest *request = [PKTItemsAPI requestForItemWithID:123];
  expect(request.path).to.equal(@"/item/123");
}

- (void)testRequestToGetItemByExternalID {
  PKTRequest *request = [PKTItemsAPI requestForItemWithExternalID:123 inAppWithID:456];
  expect(request.path).to.equal(@"/item/app/456/external_id/123");
}

- (void)testRequestToGetFilteredItems {
  PKTRequest *request = [PKTItemsAPI requestForFilteredItemsInAppWithID:123
                                                                offset:60
                                                                 limit:30
                                                                sortBy:@"created_on"
                                                            descending:YES
                                                              remember:YES];
  
  expect(request.path).to.equal(@"/item/app/123/filter/");
  expect(request.parameters[@"space_id"]).to.beNil();
  expect(request.parameters[@"offset"]).to.equal(@60);
  expect(request.parameters[@"limit"]).to.equal(@30);
  expect(request.parameters[@"sort_by"]).to.equal(@"created_on");
  expect(request.parameters[@"sort_desc"]).to.equal(@YES);
  expect(request.parameters[@"remember"]).to.equal(@YES);
}

- (void)testRequestToGetFilteredItemsWithFilters {
  NSDictionary *filters = @{@"title": @"Test"};
  PKTRequest *request = [PKTItemsAPI requestForFilteredItemsInAppWithID:123
                                                                 offset:60
                                                                  limit:30
                                                                 sortBy:@"created_on"
                                                             descending:YES
                                                               remember:YES
                                                                filters:filters];
  
  expect(request.path).to.equal(@"/item/app/123/filter/");
  expect(request.parameters[@"offset"]).to.equal(@60);
  expect(request.parameters[@"limit"]).to.equal(@30);
  expect(request.parameters[@"sort_by"]).to.equal(@"created_on");
  expect(request.parameters[@"sort_desc"]).to.equal(@YES);
  expect(request.parameters[@"remember"]).to.equal(@YES);
  expect(request.parameters[@"filters"]).to.equal(filters);
}

- (void)testRequestToGetFilteredItemsWithViewID {
  PKTRequest *request = [PKTItemsAPI requestForFilteredItemsInAppWithID:123
                                                                offset:60
                                                                 limit:30
                                                                viewID:456
                                                              remember:YES];

  expect(request.path).to.equal(@"/item/app/123/filter/456/");
  expect(request.parameters[@"offset"]).to.equal(@60);
  expect(request.parameters[@"limit"]).to.equal(@30);
  expect(request.parameters[@"remember"]).to.equal(@YES);
}

- (void)testRequestToGetFilteredItemsBySpaceAndApp {
  PKTRequest *request = [PKTItemsAPI requestForFilteredItemsInAppWithID:111
                                                                spaceID:222
                                                                 offset:60
                                                                  limit:30
                                                                 sortBy:@"created_on"
                                                             descending:YES
                                                               remember:YES
                                                                filters:nil];
  
  expect(request.path).to.equal(@"/item/app/111/filter/");
  expect(request.parameters[@"space_id"]).to.equal(@222);
  expect(request.parameters[@"offset"]).to.equal(@60);
  expect(request.parameters[@"limit"]).to.equal(@30);
  expect(request.parameters[@"sort_by"]).to.equal(@"created_on");
  expect(request.parameters[@"sort_desc"]).to.equal(@YES);
  expect(request.parameters[@"remember"]).to.equal(@YES);
}

@end
