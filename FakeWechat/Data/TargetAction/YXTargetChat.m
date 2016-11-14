//
//  FWTargetChat.m
//  FakeWechat
//
//  Created by Aren on 2016/11/11.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "YXTargetChat.h"
#import "FWChatViewController.h"
#import "FWSession.h"
#import "FWRootTabBarController.h"
#import "FWMessageListViewController.h"

@implementation YXTargetChat
- (id)privateChatAction:(NSDictionary *)aDict
{
    NSString *userId = [aDict objectForKey:@"targetId"];
    RCConversationType conversationType = [[aDict objectForKey:@"type"] integerValue];
    FWChatViewController *chatVC = [FWChatViewController chatViewControllerWithUid:userId conversationType:conversationType];
    chatVC.hidesBottomBarWhenPushed = YES;
    if ([FWSession shareInstance].isLogin) {
        FWRootTabBarController *rootTabbarController = rootTabBarController();
        [rootTabbarController setSelectedIndex:0];
        UINavigationController *navController = [rootTabbarController.viewControllers objectAtIndex:0];
        [navController pushViewController:chatVC animated:YES];
    }
    return chatVC;
}
@end
