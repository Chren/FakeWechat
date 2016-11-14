//
//  YDChatListCell.m
//  yxtk
//
//  Created by Aren on 15/6/24.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "FWChatListCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FWChatListModel.h"
#import "M13BadgeView.h"
#import "ORColorUtil.h"
#import "ORDateUtil.h"
#import "FWSession.h"

@interface FWChatListCell()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end

@implementation FWChatListCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageLabel.text = @"";
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.layer.masksToBounds = YES;
    [self layoutIfNeeded];
}

- (void)bindWithModel:(RCConversationModel *)aModel
{
    if (aModel.isTop) {
        self.backgroundColor = ORColor(@"f3f3f7");
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    if (aModel.conversationType == ConversationType_PRIVATE) {
        RCUserInfo *userInfo = [[FWSession shareInstance] getUserInfoWithUserId:aModel.targetId];
        self.userNameLabel.text = userInfo.name;
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"DefaultHead"]];
    } else {
        self.userNameLabel.text = aModel.conversationTitle;
    }
    
    RCMessageContent *messageContent = aModel.lastestMessage;
    if ([messageContent isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMessage = (RCTextMessage *)messageContent;
        self.messageLabel.text = textMessage.content;
    } else if ([messageContent isKindOfClass:[RCImageMessage class]]) {
        self.messageLabel.text = @"[图片]";
    } else if ([messageContent isKindOfClass:[RCLocationMessage class]]) {
        self.messageLabel.text = @"[地理位置]";
    } else if ([messageContent isKindOfClass:[RCVoiceMessage class]]) {
        self.messageLabel.text = @"[语音]";
    } else if ([messageContent respondsToSelector:@selector(conversationDigest)]) {
        self.messageLabel.text = [messageContent conversationDigest];
    }
    
    self.badgeView.hidden = aModel.unreadMessageCount<=0;
    if (aModel.sentTime > 0) {
        self.dateLabel.text = [ORDateUtil formatDateForMessageCellWithTimeInterval:aModel.sentTime/1000];
    } else {
        self.dateLabel.text = nil;
    }
    
    __weak typeof(self) weakself = self;
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:aModel.conversationType targetId:aModel.targetId success:^(RCConversationNotificationStatus nStatus) {
        weakself.notificationOffImageView.hidden = nStatus;
    } error:^(RCErrorCode status) {
        
    }];
}

+ (CGFloat)heightForCell
{
    return 68;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.notificationOffImageView.hidden = YES;
    self.userNameLabel.text = @"";
    self.messageLabel.text = @"";
}
@end
