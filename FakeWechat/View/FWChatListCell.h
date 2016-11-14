//
//  YDChatListCell.h
//  yxtk
//
//  Created by Aren on 15/6/24.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "MGSwipeTableCell.h"

@interface FWChatListCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UIImageView *notificationOffImageView;

- (void)bindWithModel:(RCConversationModel *)aModel;
+ (CGFloat)heightForCell;
@end
