//
//  PKCSecurity.m
//  PodioKit
//
//  Created by Sebastian Rehnby on 24/10/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCSecurity.h"
#import "PKCMacros.h"
#import "NSArray+PKCAdditions.h"

/**
 *  Returns the public key of a certificate.
 *
 *  @param certificate The certificate to extract the public key from.
 *
 *  @return The public key of the certificate.
 */
static id PKCPublicKeyForCertificate(SecCertificateRef certificate) {
  id publicKey = nil;
  
  SecCertificateRef tempCertificates[1];
  tempCertificates[0] = certificate;
  CFArrayRef certificates = CFArrayCreate(NULL, (const void **)tempCertificates, 1, NULL);
  
  SecPolicyRef policy = SecPolicyCreateBasicX509();
  SecTrustRef trust = NULL;
  OSStatus status = SecTrustCreateWithCertificates(certificates, policy, &trust);
  
  if (status == errSecSuccess) {
    status = SecTrustEvaluate(trust, NULL);
    
    if (status == errSecSuccess) {
      publicKey = (__bridge_transfer id)SecTrustCopyPublicKey(trust);
    }
  }
  
  if (policy) {
    CFRelease(policy);
  }
  
  if (certificates) {
    CFRelease(certificates);
  }
  
  if (trust) {
    CFRelease(trust);
  }
  
  return publicKey;
}

/**
 *  Extracts the public key from a certificate in NSData format.
 *
 *  @param certificateData The NSData containing the certificate file.
 *
 *  @return The public key of the certificate.
 */
static id PKCPublicKeyForCertificataData(NSData *certificateData) {
  id publicKey = nil;
  
  SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData);
  if (certificate) {
    publicKey = PKCPublicKeyForCertificate(certificate);
    CFRelease(certificate);
  }
  
  return publicKey;
}

/**
 *  Extracts all the public keys of all the certificates in a trust.
 *
 *  @param trust The trust containing the certificates.
 *
 *  @return An array of public keys.
 */
static NSArray * PKCPublicKeysFromTrust(SecTrustRef trust) {
  NSMutableArray *publicKeys = [NSMutableArray new];
  
  CFIndex count = SecTrustGetCertificateCount(trust);
  for (CFIndex i = 0; i < count; ++i) {
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(trust, i);
    id publicKey = PKCPublicKeyForCertificate(certificate);
    [publicKeys addObject:publicKey];
  }
  
  return [publicKeys copy];
}

#if !PKC_IOS_SDK_AVAILABLE
static NSData * PKCDataForKey(SecKeyRef key) {
  NSData *data = nil;
  
  CFDataRef dataRef = NULL;
  OSStatus status = SecItemExport(key, kSecFormatUnknown, kSecItemPemArmour, NULL, &dataRef);
  if (status == errSecSuccess) {
    data = (__bridge_transfer NSData *)dataRef;
  } else {
    if (dataRef) {
      CFRelease(dataRef);
    }
  }
  
  return data;
}
#endif

static BOOL PKCKeyIsEqualToKey(SecKeyRef key1, SecKeyRef key2) {
#if PKC_IOS_SDK_AVAILABLE
  return [(__bridge id)key1 isEqual:(__bridge id)key2];
#else
  return [PKCDataForKey(key1) isEqual:PKCDataForKey(key2)];
#endif
}

@interface PKCSecurity ()

@property (nonatomic, copy) NSArray *pinnedPublicKeys;

@end

@implementation PKCSecurity

#pragma mark - Private

- (NSArray *)pinnedPublicKeys {
  if (!_pinnedPublicKeys) {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];
    
    _pinnedPublicKeys = [paths pkc_mappedArrayWithBlock:^id(NSString *path) {
      NSData *certificateData = [NSData dataWithContentsOfFile:path];
      return PKCPublicKeyForCertificataData(certificateData);
    }];
  }
  
  return _pinnedPublicKeys;
}

#pragma mark - Public

- (BOOL)evaluateServerTrust:(SecTrustRef)trust {
  BOOL foundValidPublicKey = NO;
  
  NSArray *serverPublicKeys = PKCPublicKeysFromTrust(trust);
  
  // Check that at public key of at least one of the certificates in the trust
  // matches that of a pinned certificate.
  for (id serverKey in serverPublicKeys) {
    for (id pinnedKey in self.pinnedPublicKeys) {
      if (PKCKeyIsEqualToKey((__bridge SecKeyRef)serverKey, (__bridge SecKeyRef)pinnedKey)) {
        foundValidPublicKey = YES;
        break;
      }
    }
    
    if (foundValidPublicKey) {
      break;
    }
  }
  
  return foundValidPublicKey;
}

@end
