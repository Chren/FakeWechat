//
//  FWSession.h
//  FakeWechat
//
//  Created by Aren on 2016/10/27.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
#import "FWUserModel.h"
#import "FWFriendListModel.h"

/**
 *  登录状态
 */
static NSString * const kKeyPathLoginState = @"loginState";

/**
 *  用户信息
 */
static NSString * const kKeyPathSessionInfo = @"sessionInfo";

@interface FWSession : NSObject
<RCIMUserInfoDataSource>
@property (readonly, nonatomic) NSNumber *loginState;

@property (readonly, nonatomic) FWLoginUserModel *sessionInfo;

@property (strong, nonatomic) FWFriendListModel *friendListModel;
+ (instancetype)shareInstance;

- (void)updateUserInfo;

- (void)autoLogin;

- (BOOL)isLogin;

- (void)loginWithPhone:(NSString *)aPhone
              password:(NSString *)aPassword
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure;

- (void)logout;

- (RCUserInfo *)getUserInfoWithUserId:(NSString *)userId;
@end
