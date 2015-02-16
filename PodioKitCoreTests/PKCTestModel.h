//
//  PKCTestModel.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 15/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCModel.h"

@class PKCNestedTestModel;

@interface PKCTestModel : PKCModel

@property (nonatomic, readonly) NSUInteger objectID;
@property (nonatomic, copy, readonly) NSString *firstValue;
@property (nonatomic, copy, readonly) NSString *secondValue;
@property (nonatomic, copy, readonly) NSArray *nestedObjects;
@property (nonatomic, copy, readonly) PKCNestedTestModel *nestedObject;

@end
