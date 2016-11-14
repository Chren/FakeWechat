//
//  FWFriendListModel.h
//  FakeWechat
//
//  Created by Aren on 2016/10/28.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "ORBaseListModel.h"
#import "FWUserModel.h"

@interface FWFriendListModel : NSObject
- (NSArray *)getArray;
- (NSUInteger)count;
- (void)fetchList;
- (FWUserModel *)userInfoWithUserid:(long long)aUserId;
@end
