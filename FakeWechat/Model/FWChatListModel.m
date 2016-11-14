//
//  FWChatListModel.m
//  FakeWechat
//
//  Created by Aren on 2016/10/28.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWChatListModel.h"
#import <RongIMKit/RongIMKit.h>
#import "FWUnreadManager.h"
#import "FWSession.h"

@implementation FWChatListModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _displayTypeList = @[@(ConversationType_PRIVATE), @(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP),@(ConversationType_SYSTEM), @(ConversationType_CUSTOMERSERVICE)];
    [[FWUnreadManager shareInstance] addObserver:self forKeyPath:kKeyPathTotalUnreadCount options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc
{
    [[FWUnreadManager shareInstance] removeObserver:self forKeyPath:kKeyPathTotalUnreadCount];
}

- (void)fetchList
{
    NSArray *array = [[RCIMClient sharedRCIMClient] getConversationList:self.displayTypeList];
    NSMutableArray *rongArray = [[NSMutableArray alloc] init];
    BOOL hasService = NO;
    for (RCConversation *conversion in array) {
        RCConversationModel *model = [[RCConversationModel alloc] init:RC_CONVERSATION_MODEL_TYPE_NORMAL conversation:conversion extend:nil];
  
        if (model.conversationType == ConversationType_PRIVATE || model.conversationType == ConversationType_SYSTEM) {
            RCUserInfo *userInfo = [[FWSession shareInstance] getUserInfoWithUserId:model.targetId];
            model.conversationTitle = userInfo.name;
        } else {
            model.conversationTitle = conversion.conversationTitle;
        }
        if (model.conversationType == ConversationType_DISCUSSION && model.conversationTitle.length == 0) {
            [[RCIMClient sharedRCIMClient] getDiscussion:model.targetId success:^(RCDiscussion *discussion) {
                model.conversationTitle = discussion.discussionName;
            } error:^(RCErrorCode status) {
                
            }];
        }
        [rongArray addObject:model];
    }
    [self setArray:rongArray];
}

- (void)removeConversationAtIndex:(NSInteger)anIndex
{
    RCConversationModel *model = [self objectAtIndex:anIndex];
    [[RCIMClient sharedRCIMClient] removeConversation:model.conversationType targetId:model.targetId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RCIMClient sharedRCIMClient] clearMessages:model.conversationType targetId:model.targetId];
    });
    
    [self removeObjectAtIndex:anIndex];
}

- (void)checkNotificationStatus:(RCConversationModel *)aModel
{
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:aModel.conversationType targetId:aModel.targetId success:^(RCConversationNotificationStatus nStatus) {
        if (nStatus == NOTIFY) {
            [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:aModel.conversationType targetId:aModel.targetId isBlocked:YES success:^(RCConversationNotificationStatus nStatus) {
                DDLogDebug(@"status success");
            } error:^(RCErrorCode status) {
                DDLogDebug(@"status error");
            }];
        }
    } error:^(RCErrorCode status) {
        
    }];
}

- (void)setConversationToTop:(NSInteger)anIndex isTop:(BOOL)isTop
{
    RCConversationModel *model = [self objectAtIndex:anIndex];
    BOOL success = [[RCIMClient sharedRCIMClient] setConversationToTop:model.conversationType targetId:model.targetId isTop:isTop];
    DDLogDebug(@"setConversationToTop success: %d", success);
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kKeyPathTotalUnreadCount])
    {
        [self fetchList];
    }
}
@end
