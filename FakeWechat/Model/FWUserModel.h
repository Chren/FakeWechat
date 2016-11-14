//
//  FWUserModel.h
//  FakeWechat
//
//  Created by Aren on 2016/10/23.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWBaseJSONModel.h"

@interface FWUserModel : FWBaseJSONModel
@property (assign, nonatomic) NSInteger userid;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *photo;
@property (copy, nonatomic) NSString *bgimg;
@property (copy, nonatomic) NSString *pinyinname;
@end

@interface FWLoginUserModel : FWUserModel
@property (copy, nonatomic) NSString *wechatid;
@property (copy, nonatomic) NSString *token;
@property (copy, nonatomic) NSString *rctoken;
- (instancetype)initWithUserModel:(FWUserModel *)userModel;
@end

@protocol FWUserModel
@end

@interface FWFriendList : FWBaseJSONModel
@property (strong, nonatomic) NSArray<FWUserModel> *result;
@end
