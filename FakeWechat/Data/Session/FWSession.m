//
//  FWSession.m
//  FakeWechat
//
//  Created by Aren on 2016/10/27.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWSession.h"
#import "GSFileManager.h"
#import "CocoaSecurity.h"
#import "YXHttpClient.h"
#import "FWBaseResponseModel.h"
#import "FWErrorDef.h"
#import "YXHttpClient+Account.h"
#import "FWFriendListModel.h"

/**
 *  登录
 */
static NSString * const FWURLLogin = @"/login";

/**
 *  注销
 */
static NSString * const FWURLLogout = @"/logout";

@interface FWSession()
{
    dispatch_queue_t _queue;
}
@property (strong, nonatomic) NSNumber *loginState;
@property (strong, nonatomic) FWLoginUserModel *sessionInfo;
@end
@implementation FWSession

+ (instancetype)shareInstance
{
    static FWSession *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[[self class] alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("session_gcd_mark", DISPATCH_QUEUE_CONCURRENT);
        _friendListModel = [[FWFriendListModel alloc] init];
    }
    return self;
}

- (void)autoLogin
{
    [self _loadSessionInfo];
    if (self.isLogin) {
        [self _schedulesAfterAutoLoginSuccess];
    }
}

- (BOOL)isLogin
{
    return [self.loginState boolValue];
}


#pragma mark - Session
- (void)_loadSessionInfo
{
    if (_sessionInfo == nil)
    {
        NSString *filePath = [[GSFileManager sharedManager] pathForDomain:GSFileDirDomain_Pub appendPathName:kKeyPathSessionInfo];
        
        FWLoginUserModel *sessionInfo = [[GSFileManager sharedManager] loadObjectAtFilePath:filePath];
        if (sessionInfo != nil)
        {
            _sessionInfo = sessionInfo;
            if (_sessionInfo.token.length > 0) {
                self.loginState = @(1);
            }
        }
    }
}

- (void)setSessionInfo:(FWLoginUserModel *)sessionInfo
{
    if (sessionInfo) {
        [self willChangeValueForKey:kKeyPathSessionInfo];
        _sessionInfo = sessionInfo;
        [self didChangeValueForKey:kKeyPathSessionInfo];
        dispatch_barrier_async(_queue, ^{
            NSString *filePath = [[GSFileManager sharedManager] pathForDomain:GSFileDirDomain_Pub appendPathName:kKeyPathSessionInfo];
            [[GSFileManager sharedManager] saveObject:sessionInfo atFilePath:filePath];
        });
    } else {
        [self willChangeValueForKey:kKeyPathSessionInfo];
        _sessionInfo = sessionInfo;
        [self didChangeValueForKey:kKeyPathSessionInfo];
        dispatch_barrier_async(_queue, ^{
            NSString *filePath = [[GSFileManager sharedManager] pathForDomain:GSFileDirDomain_Pub appendPathName:kKeyPathSessionInfo];
            [[GSFileManager sharedManager] removeFileAtPath:filePath];
        });
    }
}

- (void)updateFriendList
{
    [self.friendListModel fetchList];
}

- (void)updateUserInfo
{
    __weak typeof(self) weakself = self;
    [[YXHttpClient sharedClient] getUserInfoWithUserId:self.sessionInfo.userid success:^(NSURLSessionDataTask *task, id responseObject) {
        FWBaseResponseModel *response = (FWBaseResponseModel *)responseObject;
        if (response.errorcode == FWErrorCMSuccess) {
            NSError *error = nil;
            FWLoginUserModel *userInfo = [[FWLoginUserModel alloc] initWithDictionary:response.data error:&error];
            userInfo.token = weakself.sessionInfo.token;
            userInfo.rctoken = weakself.sessionInfo.rctoken;
            userInfo.wechatid = weakself.sessionInfo.wechatid;
            weakself.sessionInfo = userInfo;
            [weakself _schedulesAfterAutoLoginSuccess];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}
#pragma mark - login/logout
- (void)_schedulesAfterAutoLoginSuccess
{
    [[GSFileManager sharedManager] createUserDirWithUserId:@(self.sessionInfo.userid).stringValue];
    self.loginState = @(1);
    [self updateFriendList];
    [self _connectRongCloudWithCompletion:nil];
}

- (void)loginWithPhone:(NSString *)aPhone
              password:(NSString *)aPassword
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
{
    NSString *encodedPassword = [CocoaSecurity md5:aPassword].hexLower;
    NSDictionary *paramDict =  @{@"phone":aPhone, @"password":encodedPassword};
    __weak typeof(self) weakself = self;
    [[YXHttpClient sharedClient] performRequestWithUrl:FWURLLogin httpMethod:YXHttpTypePost param:paramDict success:^(NSURLSessionDataTask *task, id responseObject) {
        FWBaseResponseModel *response = (FWBaseResponseModel *)responseObject;
        if (response.errorcode == FWErrorCMSuccess) {
            NSError *error = nil;
            FWLoginUserModel *sessionInfo = [[FWLoginUserModel alloc] initWithDictionary:response.data error:&error];
            weakself.sessionInfo = sessionInfo;
            [weakself _schedulesAfterAutoLoginSuccess];
        }
        if (aSuccess) {
            aSuccess(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)logout
{
    [[YXHttpClient sharedClient] performRequestWithUrl:FWURLLogout httpMethod:YXHttpTypePost param:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
    [[RCIMClient sharedRCIMClient] logout];
    [self _schedulesAfterLogoutSuccess];
}

- (void)_schedulesAfterLogoutSuccess
{
    self.sessionInfo = nil;
    self.loginState = @(0);
}

#pragma mark - 融云
- (void)_connectRongCloudWithCompletion:(void (^)(BOOL success, NSInteger errorcode))completion
{
    if (!self.sessionInfo.rctoken || [self.sessionInfo.rctoken isEqualToString:@"null"]) {
        if (completion) {
            completion(NO, 31004);
        }
        return;
    }
    __weak typeof(self) weakself = self;
    [[RCIM sharedRCIM] connectWithToken:self.sessionInfo.rctoken success:^(NSString *userId) {
        RCUserInfo *currentUserInfo = [[RCUserInfo alloc] init];
        currentUserInfo.userId = [NSString stringWithFormat:@"%ld", (long)weakself.sessionInfo.userid];
        currentUserInfo.name = weakself.sessionInfo.name;
        currentUserInfo.portraitUri = weakself.sessionInfo.photo;
        [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
        [RCIM sharedRCIM].currentUserInfo = currentUserInfo;
        [[RCIM sharedRCIM] refreshUserInfoCache:currentUserInfo withUserId:userId];
        if (completion) {
            completion(YES, 0);
        }
        dispatch_async(_queue, ^{
            [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
        });
    } error:^(RCConnectErrorCode status) {
        DDLogDebug(@"RCIM connect failed!status:%ld", (long)status);
        if (completion) {
            completion(NO, status);
        }
    } tokenIncorrect:^{
        DDLogDebug(@"RCIM connect failed:incorrect token!");
        if (completion) {
            completion(NO, 31004);
        }
    }];
}

- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status;
{
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        if (self.isLogin) {
            [[RCIMClient sharedRCIMClient] logout];
            [self _schedulesAfterLogoutSuccess];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"系统提示" message:NSLocalizedString(@"您的账号在其他设备登录，请重新登录", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [view show];
            });
        }
    }
}

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion
{
    RCUserInfo *userInfo = [self getUserInfoWithUserId:userId];
    if (userInfo) {
        completion(userInfo);
    } else {
        completion(nil);
        // TODO: 获取单用户信息
//        [[YXHttpClient sharedClient] getUserInfoWithUserId:userId success:^(NSURLSessionDataTask *task, id responseObject) {
//            YDBaseResponseModel *response = (YDBaseResponseModel *)responseObject;
//            if (response.errorCode == YDErrorCMSuccess) {
//                RCUserInfo *rcUserInfo = [[RCUserInfo alloc] init];
//                rcUserInfo.userId = [[response.data objectForKey:@"id"] stringValue];
//                rcUserInfo.portraitUri = [response.data objectForKey:@"photoUrl"];
//                rcUserInfo.name = [response.data objectForKey:@"userName"];
//                completion(rcUserInfo);
//            }
//        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            completion(nil);
//        }];
    }
}

- (RCUserInfo *)getUserInfoWithUserId:(NSString *)userId
{
    if (userId.intValue == self.sessionInfo.userid) {
        RCUserInfo *rcUserInfo = [[RCUserInfo alloc] initWithUserId:[NSString stringWithFormat:@"%ld", (long)self.sessionInfo.userid] name:self.sessionInfo.name portrait:self.sessionInfo.photo];
        return rcUserInfo;
    }
    
    if (self.friendListModel.count == 0) {
        return nil;
    }
    
    FWUserModel *friendInfo = [self.friendListModel userInfoWithUserid:userId.longLongValue];
    if (friendInfo) {
        RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:[NSString stringWithFormat:@"%ld", (long)friendInfo.userid] name:friendInfo.name portrait:friendInfo.photo];
         return userInfo;
    } else {
        return nil;
    }
}
@end
