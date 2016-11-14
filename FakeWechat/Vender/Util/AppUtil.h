//
//  ORAPPUtil.h
//  ORead
//
//  Created by noname on 14-7-26.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kORAppPlatform @"0"
#define kORAppProductName @"oread_client"
#define kORAppDomainName @"oread.oread.com"
#define kORAppChanelId @"appstore"

@interface AppUtil : NSObject
+ (NSString *)appVersion;
+ (NSString *)appBuildVersion;
+ (NSString *)appShortVersion;
+ (NSString *)systemName;
+ (NSString *)systemVersion;
//+ (NSString *)deviceId;
+ (NSString *)deviceType;
+ (NSString *)mac;
+ (NSString *)resolution;
//+ (NSString *)uuid;

+ (NSString *)deviceInfo;   // 设备（iphone5，iphon5s。。。）
+ (NSString *)systemInfo;   // ios系统（ios6，ios7。。。）
+ (NSString *)operatorInfo; // 运营商（移动、联通。。。）
+ (NSString *)networkInfo;  // 网络（wifi，3g。。。）
+ (NSString *)localIPAddress;   // 获取内网ip
+ (NSString *)currentLanguage;
+ (NSString *)bundleId;
+ (BOOL)needUpateVersion:(NSString *)aOldVersion;
@end
