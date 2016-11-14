//
//  FWUnreadManager.m
//  FakeWechat
//
//  Created by Aren on 16/7/29.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWUnreadManager.h"

@interface FWUnreadManager()
@property (assign, nonatomic) NSInteger unreadMessageCount;
@end
@implementation FWUnreadManager
+ (instancetype)shareInstance
{
    static FWUnreadManager *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[[self class] alloc] init];
    });
    return _shareInstance;
}

- (void)checkUnreadCount
{
    if ([[RCIMClient sharedRCIMClient] getTotalUnreadCount] != self.unreadMessageCount) {
        self.unreadMessageCount = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    }
}

#pragma mark - RCIMReceiveMessageDelegate
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
{
    self.unreadMessageCount = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
}

@end
