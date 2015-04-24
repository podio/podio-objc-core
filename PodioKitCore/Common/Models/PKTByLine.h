//
//  PKTByLine.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 08/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKTModel.h"
#import "PKTConstants.h"

@class PKTFile;

@interface PKTByLine : PKTModel

@property (nonatomic, assign, readonly) PKTReferenceType referenceType;
@property (nonatomic, assign, readonly) NSUInteger referenceID;
@property (nonatomic, assign, readonly) NSUInteger userID;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) PKTFile *imageFile;
@property (nonatomic, copy, readonly) NSDate *lastSeenOn;
@property (nonatomic, assign, readonly) NSUInteger avatarID;
@property (nonatomic, assign, readonly) PKTAvatarType avatarType;

@end
