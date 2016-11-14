//
//  FWChatViewController.h
//  FakeWechat
//
//  Created by Aren on 2016/10/28.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface FWChatViewController : RCConversationViewController
@property (strong,nonatomic) RCConversationModel *conversation;

+ (FWChatViewController *)chatViewControllerWithUid:(NSString *)anUid conversationType:(RCConversationType)cType;
@end
