//
//  PKCMacros.h
//  PodioKit
//
//  Created by Sebastian Rehnby on 15/04/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

// References
#define PKC_STRONG(obj) __typeof__(obj)
#define PKC_WEAK(obj) __typeof__(obj) __weak
#define PKC_WEAK_SELF PKC_WEAK(self)

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#define PKC_IOS_SDK_AVAILABLE 1
#else
#define PKC_IOS_SDK_AVAILABLE 0
#endif