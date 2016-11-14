//
//  YXTargetActionManager.m
//  yxtk
//
//  Created by Aren on 16/7/14.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "YXTargetActionManager.h"

@implementation YXTargetActionManager
+ (instancetype)sharedInstance
{
    static YXTargetActionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YXTargetActionManager alloc] init];
    });
    return manager;
}

- (id)performTarget:(NSString *)aTargetName action:(NSString *)anActionName params:(NSDictionary *)aParams
{
    if (aTargetName.length == 0 || anActionName.length == 0) {
        return nil;
    }
    
    NSString *targetClassString = [aTargetName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[aTargetName substringToIndex:1] uppercaseString]];
    NSString *fullTargetString = [NSString stringWithFormat:@"YXTarget%@", targetClassString];
    NSString *fullActionString = [NSString stringWithFormat:@"%@:", anActionName];
    Class targetClass = NSClassFromString(fullTargetString);
    id target = [[targetClass alloc] init];
    SEL action = NSSelectorFromString(fullActionString);
    
    if (target == nil) {
        /**
         *  没有找到target则显示相应错误页面
         */
        Class exceptionTargetClass = NSClassFromString(@"YXTargetException");
        target = [[exceptionTargetClass alloc] init];
        action = NSSelectorFromString(@"show404:");
        if ([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [target performSelector:action withObject:aParams];
#pragma clang diagnostic pop
        }
        return nil;
    } else {
        if ([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [target performSelector:action withObject:aParams];
#pragma clang diagnostic pop
        } else {
            /**
             *  无参数的情况我们也要支持
             */
            fullActionString = anActionName;
            action = NSSelectorFromString(fullActionString);
            if ([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                return [target performSelector:action];
#pragma clang diagnostic pop
            } else {
                // TODO: 对应target的错误处理
            }
        }
    }
    return nil;
}

@end
