//
//  ORSetting.h
//  OReader
//
//  Created by chhren on 13-11-19.
//  Copyright (c) 2013年 ORead. All rights reserved.
//

#import <Foundation/Foundation.h>
//onNotification
#define NOTIFICATION_NAME @"Notification_Name"
#define NOTIFICATION_OBJECT @"Notification_Object"
#define NOTIFICATION_USERINFO @"Notification_UserInfo"

#define kNotificationUserLogin @"kNotificationUserLogin"
#define kNotificationUserLogout @"kNotificationUserLogout"
#define kORObserverEnterForeground @"kORObserverEnterForeground"
#define kORNetworkStatusChanged @"kORNetworkStatusChanged"
#define kORNewRCMessage @"kORNewRCMessage"
@interface Observer : NSObject
+ (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)aObject userInfo:(NSDictionary *)aUserInfo;
@end
