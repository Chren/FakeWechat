//
//  ORSecurityUtil.m
//  ORead
//
//  Created by noname on 14-7-26.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import "SecurityUtil.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "Base64.h"

#pragma mark -
#pragma mark - checksum
static NSString * const kAFCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString * AFPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kAFCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

static NSString * AFPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kAFCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}


@interface YDQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

@implementation YDQueryStringPair

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return AFPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", AFPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding), AFPercentEscapedQueryStringValueFromStringWithEncoding([self.value description], stringEncoding)];
    }
}

@end

extern NSArray * YDQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * YDQueryStringPairsFromKeyAndValue(NSString *key, id value);

static NSString * YDQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (YDQueryStringPair *pair in YDQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * YDQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return YDQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * YDQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:YDQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:YDQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:YDQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[YDQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

@implementation SecurityUtil
+ (NSString *)aesEncryptUrs:(NSString *)aString key:(NSString *)aKey
{
    NSAssert(aKey.length > 0, @"aesEncrypt key should not empty!");
    NSData *data = [aString dataUsingEncoding:NSUTF8StringEncoding];
    
    CocoaSecurityDecoder *decoder = [CocoaSecurityDecoder new];
    NSData *aesKey = [decoder hex:aKey];
    
    CocoaSecurityResult *result = [self aesEncryptWithData:data key:aesKey];
    
    return result.hexLower;
}

+ (NSString *)aesDecryptUrs:(NSString *)aString key:(NSString *)aKey
{
    NSAssert(aKey.length > 0, @"aesDecrypt key should not empty!");
    CocoaSecurityDecoder *decoder = [CocoaSecurityDecoder new];
    NSData *data = [decoder hex:aString];
    NSData *aesKey = [decoder hex:aKey];
    
    CocoaSecurityResult *result = [self aesDecryptWithData:data key:aesKey];
    return result.utf8String;
}


+ (CocoaSecurityResult *)aesEncryptWithData:(NSData *)data key:(NSData *)key
{
    // check length of key
    if ([key length] != 16 && [key length] != 24 && [key length] != 32 ) {
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Length of key is wrong. Length of iv should be 16, 24 or 32(128, 192 or 256bits)"
                                     userInfo:nil];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key bytes],     // Key
                                          [key length],    // kCCKeySizeAES
                                          NULL,       // IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:buffer length:encryptedSize];
        free(buffer);
        
        return result;
    }
    else {
        free(buffer);
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Encrypt Error!"
                                     userInfo:nil];
        return nil;
    }
}

+ (CocoaSecurityResult *)aesDecryptWithData:(NSData *)data key:(NSData *)key
{
    // check length of key
    if ([key length] != 16 && [key length] != 24 && [key length] != 32 ) {
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Length of key is wrong. Length of iv should be 16, 24 or 32(128, 192 or 256bits)"
                                     userInfo:nil];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key bytes],     // Key
                                          [key length],    // kCCKeySizeAES
                                          NULL,       // IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:buffer length:encryptedSize];
        free(buffer);
        
        return result;
    }
    else {
        free(buffer);
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Decrypt Error!"
                                     userInfo:nil];
        return nil;
    }
}

+ (NSString *)checksumFromParameters:(NSDictionary *)parameters salt:(NSString *)aSalt api:(NSString *)anApi deviceid:(NSString *)aDeviceId
{
    NSString *joinedParamStr = YDQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding);
    NSString *fullEncodedStr = [NSString stringWithFormat:@"%@%@%@", aSalt, joinedParamStr, aSalt];
    NSString *firstStepStr = [fullEncodedStr MD5];
    NSString *secondStepStr = [NSString stringWithFormat:@"%@%@%@", firstStepStr, anApi, aDeviceId];
    return [secondStepStr MD5];
}

+ (NSString *)checksumFromParameters:(NSDictionary *)parameters salt:(NSString *)aSalt
{
    NSString *joinedParamStr = YDQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding);
    NSString *fullEncodedStr = [NSString stringWithFormat:@"%@%@%@", aSalt, joinedParamStr, aSalt];
    NSString *firstStepStr = [fullEncodedStr MD5];
    NSString *secondStepStr = [NSString stringWithFormat:@"%@%@", firstStepStr, aSalt];
    return [secondStepStr MD5];
}

+ (NSString *)queryStringFromParameters:(NSDictionary *)aParam
{
    if (!aParam) {
        return nil;
    }
    NSString *joinedParamStr = YDQueryStringFromParametersWithEncoding(aParam, NSUTF8StringEncoding);
    return joinedParamStr;
}

+ (NSString *)sha1:(NSString *)hashString
{
    CocoaSecurityResult *result = [CocoaSecurity sha1:hashString];
    return result.hexLower;
}
@end

@implementation NSString (MD5)

- (NSString *)MD5
{
    CocoaSecurityResult *result = [CocoaSecurity md5:self];
    return result.hexLower;
}
@end

@implementation NSData (MD5)

- (NSString *)MD5
{
    CocoaSecurityResult *result = [CocoaSecurity md5WithData:self];
    return result.hexLower;
}
@end
