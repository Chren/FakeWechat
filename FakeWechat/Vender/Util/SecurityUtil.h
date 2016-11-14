//
//  ORSecurityUtil.h
//  ORead
//
//  Created by noname on 14-7-26.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import "CocoaSecurity.h"

@interface SecurityUtil : CocoaSecurity
/**
 *  AES加密
 *
 *  @param aString 要加密的串
 *  @param aKey    秘钥
 *
 *  @return 加密后的hexstring
 */
+ (NSString *)aesEncryptUrs:(NSString *)aString key:(NSString *)aKey;

/**
 *  AES解密
 *
 *  @param aString 要解密的串
 *  @param aKey    秘钥
 *
 *  @return 解密后的字符串
 */
+ (NSString *)aesDecryptUrs:(NSString *)aString key:(NSString *)aKey;

/**
 *  生成校验码
 *
 *  @param parameters 参数列表
 *
 *  @return 校验码
 */
+ (NSString *)checksumFromParameters:(NSDictionary *)parameters salt:(NSString *)aSalt api:(NSString *)anApi deviceid:(NSString *)aDeviceId;

+ (NSString *)checksumFromParameters:(NSDictionary *)parameters salt:(NSString *)aSalt;

+ (NSString *)queryStringFromParameters:(NSDictionary *)aParam;

+ (NSString *)sha1:(NSString *)hashString;
@end

@interface NSString (MD5)

- (NSString *)MD5;

@end

@interface NSData (MD5)

- (NSString *)MD5;

@end


