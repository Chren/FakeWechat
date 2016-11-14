//
//  YXHttpClient+Message.m
//  FakeWechat
//
//  Created by Aren on 2016/11/8.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "YXHttpClient+Message.h"
#import "FWDataEngine.h"
#import "FWBaseResponseModel.h"

@implementation YXHttpClient (Message)
- (NSURLSessionDataTask *)sendMagicSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
{
    NSURLSessionDataTask *task = [[YXHttpClient sharedClient] performRequestWithUrl:FWURLMessageMagic httpMethod:YXHttpTypePost param:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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

- (NSURLSessionDataTask *)sendMessageRouterFrom:(NSString *)fromUid to:(NSString *)toUid message:(RCMessageContent *)aContent Success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
{
    NSString *objectName = [[aContent class] getObjectName];
    NSString *content = [[NSString alloc] initWithData:[aContent encode] encoding:4];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (content.length > 0) {
        [dict setObject:content forKey:@"content"];
    }
    [dict setObject:toUid forKey:@"toUserId"];
    [dict setObject:fromUid forKey:@"extra"];
    [dict setObject:fromUid forKey:@"fromUserId"];
    [dict setObject:objectName forKey:@"objectName"];
    NSURLSessionDataTask *task = [[YXHttpClient sharedClient] performRequestWithUrl:FWURLMessageRouter httpMethod:YXHttpTypePost param:dict success:^(NSURLSessionDataTask *task, id responseObject) {
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
