//
//  FWUnreadManager.h
//  FakeWechat
//
//  Created by Aren on 16/7/29.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

static NSString * const kKeyPathTotalUnreadCount = @"unreadMessageCount";

@interface FWUnreadManager : NSObject
<RCIMReceiveMessageDelegate>
/**
 *  消息未读数
 */
@property (readonly, nonatomic) NSInteger unreadMessageCount;
+ (instancetype)shareInstance;
- (void)checkUnreadCount;
@end
