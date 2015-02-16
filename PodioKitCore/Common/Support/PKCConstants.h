//
//  PKCConstants.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 22/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#ifndef PodioKit_PKCConstants_h
#define PodioKit_PKCConstants_h

typedef NS_ENUM(NSUInteger, PKCReferenceType) {
  PKCReferenceTypeUnknown = 0,
  PKCReferenceTypeApp,
  PKCReferenceTypeAppRevision,
  PKCReferenceTypeAppField,
  PKCReferenceTypeItem,
  PKCReferenceTypeBulletin,
  PKCReferenceTypeComment,
  PKCReferenceTypeStatus,
  PKCReferenceTypeSpaceMember,
  PKCReferenceTypeAlert,
  PKCReferenceTypeItemRevision,
  PKCReferenceTypeRating,
  PKCReferenceTypeTask,
  PKCReferenceTypeTaskAction,
  PKCReferenceTypeSpace,
  PKCReferenceTypeOrg,
  PKCReferenceTypeConversation,
  PKCReferenceTypeMessage,
  PKCReferenceTypeNotification,
  PKCReferenceTypeFile,
  PKCReferenceTypeFileService,
  PKCReferenceTypeProfile,
  PKCReferenceTypeUser,
  PKCReferenceTypeWidget,
  PKCReferenceTypeShare,
  PKCReferenceTypeForm,
  PKCReferenceTypeAuthClient,
  PKCReferenceTypeConnection,
  PKCReferenceTypeIntegration,
  PKCReferenceTypeShareInstall,
  PKCReferenceTypeIcon,
  PKCReferenceTypeOrgMember,
  PKCReferenceTypeNews,
  PKCReferenceTypeHook,
  PKCReferenceTypeTag,
  PKCReferenceTypeEmbed,
  PKCReferenceTypeQuestion,
  PKCReferenceTypeQuestionAnswer,
  PKCReferenceTypeAction,
  PKCReferenceTypeContract,
  PKCReferenceTypeMeeting,
  PKCReferenceTypeBatch,
  PKCReferenceTypeSystem,
  PKCReferenceTypeSpaceMemberRequest,
  PKCReferenceTypeLive,
  PKCReferenceTypeItemParticipation
};

#pragma mark - Workspaces

typedef NS_ENUM(NSUInteger, PKCWorkspacePrivacy) {
  PKCWorkspacePrivacyUnknown = 0,
  PKCWorkspacePrivacyOpen,
  PKCWorkspacePrivacyClosed
};

typedef NS_ENUM(NSUInteger, PKCWorkspaceMemberRole) {
  PKCWorkspaceMemberRoleUnknown = 0,
  PKCWorkspaceMemberRoleLight,
  PKCWorkspaceMemberRoleRegular,
  PKCWorkspaceMemberRoleAdmin
};

typedef NS_ENUM(NSUInteger, PKCWorkspaceType) {
  PKCWorkspaceTypeUnknown = 0,
  PKCWorkspaceTypeRegular,
  PKCWorkspaceTypeEmployeeNetwork,
  PKCWorkspaceTypeDemo
};

#pragma mark - Apps

typedef NS_ENUM(NSUInteger, PKCAppFieldType) {
  PKCAppFieldTypeUnknown = 0,
  PKCAppFieldTypeText,
  PKCAppFieldTypeNumber,
  PKCAppFieldTypeImage,
  PKCAppFieldTypeDate,
  PKCAppFieldTypeApp,
  PKCAppFieldTypeContact,
  PKCAppFieldTypeMoney,
  PKCAppFieldTypeProgress,
  PKCAppFieldTypeLocation,
  PKCAppFieldTypeDuration,
  PKCAppFieldTypeEmbed,
  PKCAppFieldTypeCalculation,
  PKCAppFieldTypeCategory,
};

typedef NS_ENUM(NSUInteger, PKCCategoryOptionStatus) {
  PKCCategoryOptionStatusUnknown = 0,
  PKCCategoryOptionStatusActive,
  PKCCategoryOptionStatusDeleted
};

typedef NS_ENUM(NSInteger, PKCEmbedType) {
  PKCEmbedTypeUnknown = 0,
  PKCEmbedTypeImage,
  PKCEmbedTypeVideo,
  PKCEmbedTypeRich,
  PKCEmbedTypeLink,
  PKCEmbedTypeUnresolved
};

typedef NS_ENUM(NSUInteger, PKCImageSize) {
  PKCImageSizeOriginal,
  PKCImageSizeDefault,     // 40x40
  PKCImageSizeTiny,        // 16x16
  PKCImageSizeSmall,       // 32x32
  PKCImageSizeMedium,      // 80x80
  PKCImageSizeLarge,       // 160x160
  PKCImageSizeExtraLarge,  // 520x?
};

#pragma mark - Tasks

typedef NS_ENUM(NSUInteger, PKCTaskStatus) {
  PKCTaskStatusActive,
  PKCTaskStatusCompleted,
};

#endif
