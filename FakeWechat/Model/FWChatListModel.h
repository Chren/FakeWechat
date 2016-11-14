//
//  FWChatListModel.h
//  FakeWechat
//
//  Created by Aren on 2016/10/28.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "ORBaseListModel.h"

@interface FWChatListModel : ORBaseListModel
@property (strong, nonatomic) NSArray *displayTypeList;

- (void)removeConversationAtIndex:(NSInteger)anIndex;

- (void)setConversationToTop:(NSInteger)anIndex isTop:(BOOL)isTop;
@end
