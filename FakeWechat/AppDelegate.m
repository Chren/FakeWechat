//
//  AppDelegate.m
//  FakeWechat
//
//  Created by Aren on 2016/10/20.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "AppDelegate.h"
#import "FWDataEngine.h"
#import <RongIMKit/RongIMKit.h>
#import "ORColorUtil.h"
#import "FWSession.h"
#import "FWUnreadManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FWProposalMessage.h"

#define kDeviceToken @"RongCloud_SDK_DeviceToken"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // 初始化DDLog
    [self initRongCloud];
    [self initSDWebImage];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [FWDataEngine shareInstance];
    [self registerUserNotification];
    
    [[FWSession shareInstance] autoLogin];
    
    application.applicationIconBadgeNumber = 0;
    return YES;
}

- (void)registerUserNotification
{
    // 注册远程消息
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert |
        UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#pragma clang diagnostic pop
    }
}

- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

#pragma mark - 第三方库初始化

- (void)initRongCloud
{
    [RCIM sharedRCIM].globalNavigationBarTintColor = ORColor(@"ffffff");
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    [RCIM sharedRCIM].userInfoDataSource = [FWSession shareInstance];
    [[RCIM sharedRCIM] setReceiveMessageDelegate:[FWUnreadManager shareInstance]];
    [RCIM sharedRCIM].portraitImageViewCornerRadius = 0;
    [[RCIMClient sharedRCIMClient] registerMessageType:FWProposalMessage.class];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
}

- (void)initSDWebImage
{
    /**
     *  Add userAgent
     */
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    
    [[SDWebImageDownloader sharedDownloader] setValue:userAgent forHTTPHeaderField:@"User-Agent"];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    DDLogDebug(@"deviceToken:%@",deviceToken);
    NSString *token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    [UIApplication sharedApplication].applicationIconBadgeNumber =
    [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
