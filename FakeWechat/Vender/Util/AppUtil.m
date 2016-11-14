//
//  ORAPPUtil.m
//  ORead
//
//  Created by noname on 14-7-26.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import "AppUtil.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <UIDevice+iAppInfos.h>
#import "AppInformationsManager.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
@implementation AppUtil
+ (NSString *)platform
{
    //    0:ios 1: andoid
    return @"0";
}

+ (NSString *)productName
{
    return @"oread_client";
}

+ (NSString *)appVersion
{
    static NSString *version = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        version = [infoDict objectForKey:@"CFBundleVersion"];
    });

    return version;
}

+ (NSString *)appBuildVersion
{
    static NSString *version = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    });

    return version;
}

+ (NSString *)appShortVersion
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)systemName
{
    static NSString *name = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        name = [UIDevice currentDevice].systemName;
    });
    return name;
}

+ (NSString *)systemVersion
{
    static NSString *version = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion;
    });
    
    return version;
}

//+ (NSString *)deviceId
//{
//    static NSString *deviceId = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        deviceId = nil;
//    });
//
//    return deviceId;
//}

+ (NSString *)deviceInfo
{
    return [UIDevice jmo_modelName];
}

+ (NSString *)systemInfo
{
    return [NSString stringWithFormat:@"ios%@",[self systemVersion]];
}

+ (NSString *)operatorInfo
{
    return [[AppInformationsManager sharedManager] infoForKey:AppVersionManagerKeyOperator];
}

+ (NSString *)networkInfo
{
//    NetworkStatus status = [PomeloReachability reachabilityForInternetConnection].currentReachabilityStatus;
//    switch (status) {
//        case ReachableViaWiFi:
//            return @"wifi";
//            break;
//        case ReachableViaWWAN:
//            return @"3G/2G";
//            break;
//        case NotReachable:
//            break;
//        default:
//            break;
//    }
    return nil;
}

+ (NSString *)deviceType
{
    static NSString *deviceType = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        size_t size;
        
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        deviceType = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        free(machine);
        
        if (deviceType.length <= 0)
        {
            deviceType = @"unknown";
        }
    });
    
    return deviceType;
}

+ (NSString *)mac
{
    static NSString *macAddress = nil;
    if (macAddress == nil)
    {
        int mib[] =
        {
            CTL_NET,
            AF_ROUTE,
            0,
            AF_LINK,
            NET_RT_IFLIST,
            if_nametoindex("en0")
        };
        
        //get message size
        size_t length = 0;
        if (mib[5] == 0 || sysctl(mib, 6, NULL, &length, NULL, 0) < 0 || length == 0)
        {
            return nil;
        }
        
        //get message
        NSMutableData *data = [NSMutableData dataWithLength:length];
        if (sysctl(mib, 6, [data mutableBytes], &length, NULL, 0) < 0)
        {
            return nil;
        }
        
        //get socket address
        struct sockaddr_dl *socketAddress = ([data mutableBytes] + sizeof(struct if_msghdr));
        unsigned char *coreAddress = (unsigned char *)LLADDR(socketAddress);
        macAddress = [[NSString alloc] initWithFormat:@"%02X%02X%02X%02X%02X%02X",
                      coreAddress[0], coreAddress[1], coreAddress[2],
                      coreAddress[3], coreAddress[4], coreAddress[5]];
    }
    return macAddress;
}

+ (NSString *)resolution
{
    static NSString *size = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [NSString stringWithFormat:@"%d*%d",(int)[UIScreen mainScreen].bounds.size.width,(int)[UIScreen mainScreen].bounds.size.height];
    });
    return size;
}

//+ (NSString *)uuid
//{
//}


+ (BOOL)needUpateVersion:(NSString *)aOldVersion
{
    NSString *newVersion = [AppUtil appVersion];
    
    NSArray *aNewVersionArray = [newVersion componentsSeparatedByString:@"."];
    NSArray *aOldVersionArray = [aOldVersion componentsSeparatedByString:@"."];
    
    NSInteger length = MIN(aNewVersionArray.count, aOldVersionArray.count);
    for (int i = 0; i<length; i++)
    {
        int numNew = [aNewVersionArray[i] intValue];
        int numOld = [aOldVersionArray[i] intValue];
        
        if (numNew > numOld)
        {
            return YES;
        }
        else if(numNew < numOld)
        {
            return NO;
        }
    }
    
    if (aNewVersionArray.count > aOldVersionArray.count)
    {
        return YES;
    }
    return NO;
}

+ (NSString *)localIPAddress
{
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSString *)bundleId
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)currentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return currentLanguage;
}
@end
