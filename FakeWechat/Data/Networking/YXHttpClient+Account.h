//
//  YXHttpClient+Account.h
//  YDEducation
//
//  Created by Aren on 16/8/10.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXHttpClient.h"
/**
 *  好友列表
 */
static NSString * const FWURLFriendList = @"/friendlist";

static NSString * const FWURLUserDetail = @"/users";

@interface YXHttpClient (Account)
- (NSURLSessionDataTask *)getFriendListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure;

- (NSURLSessionDataTask *)getUserInfoWithUserId:(NSInteger)userId
                                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure;
@end
