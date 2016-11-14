//
//  FWUserModel.m
//  FakeWechat
//
//  Created by Aren on 2016/10/23.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWUserModel.h"

@implementation FWUserModel
@end

@implementation FWLoginUserModel
- (instancetype)initWithUserModel:(FWUserModel *)userModel
{
    self = [super init];
    self.userid = userModel.userid;
    self.phone = userModel.phone;
    self.name = userModel.name;
    self.photo = userModel.photo;
    self.bgimg = userModel.bgimg;
    return self;
}
@end

@implementation FWFriendList
@end
