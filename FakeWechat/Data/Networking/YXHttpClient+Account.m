//
//  YXHttpClient+Account.m
//  YDEducation
//
//  Created by Aren on 16/8/10.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "YXHttpClient+Account.h"
#import "SecurityUtil.h"
#import "FWDataEngine.h"
#import "FWBaseResponseModel.h"

@implementation YXHttpClient (Account)
- (NSURLSessionDataTask *)getFriendListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
{
    NSURLSessionDataTask *task = [[YXHttpClient sharedClient] performRequestWithUrl:FWURLFriendList httpMethod:YXHttpTypeGet param:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (aSuccess) {
            aSuccess(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (aFailure) {
            aFailure(task, error);
        }
    } cachePoclicy:YXCachePolicyFirstCacheThenRequest];
    return task;
}

- (NSURLSessionDataTask *)getUserInfoWithUserId:(NSInteger)userId
                                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
{
    NSString *fullUrl = [NSString stringWithFormat:@"%@/%d", FWURLUserDetail, (int)userId];
    NSURLSessionDataTask *task = [[YXHttpClient sharedClient] performRequestWithUrl:fullUrl httpMethod:YXHttpTypeGet param:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (aSuccess) {
            aSuccess(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (aFailure) {
            aFailure(task, error);
        }
    } cachePoclicy:YXCachePolicyNoCache];
    return task;
}
@end
