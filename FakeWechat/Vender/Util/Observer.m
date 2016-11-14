//
//  ORSetting.m
//  OReader
//
//  Created by chhren on 13-11-19.
//  Copyright (c) 2013年 ORead. All rights reserved.
//

#import "Observer.h"

@implementation Observer
+ (void)postCustomNotificationOnMainThread:(NSDictionary *)aData
{
    NSObject *name = [aData objectForKey:NOTIFICATION_NAME];
    id object = [aData objectForKey:NOTIFICATION_OBJECT];
    NSObject *userInfo = [aData objectForKey:NOTIFICATION_USERINFO];
    
    if (name == [NSNull null])
    {
        name = nil;
    }
    if (object == [NSNull null])
    {
        object = nil;
    }
    if (userInfo == [NSNull null])
    {
        userInfo = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)name object:object userInfo:(NSDictionary *)userInfo] ;
}

+ (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)aObject userInfo:(NSDictionary *)aUserInfo;
{
    NSObject *name = aName;
    id object = aObject;
    NSObject *userInfo = aUserInfo;
    if (nil == name)
    {
        name = [NSNull null];
    }
    if (nil == object) 
    {
        object = [NSNull null];
    }
    if (nil == userInfo) 
    {
        userInfo = [NSNull null];
    }
    
    NSDictionary* data = [[NSDictionary alloc] initWithObjectsAndKeys: name ,NOTIFICATION_NAME , object ,NOTIFICATION_OBJECT ,userInfo , NOTIFICATION_USERINFO, nil ] ;
    
    [Observer performSelectorOnMainThread:@selector(postCustomNotificationOnMainThread:) withObject:data waitUntilDone:NO];
}
@end
