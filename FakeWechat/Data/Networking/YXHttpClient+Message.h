//
//  YXHttpClient+Message.h
//  FakeWechat
//
//  Created by Aren on 2016/11/8.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "YXHttpClient.h"
#import <RongIMLib/RCMessageContent.h>

static NSString * const FWURLMessageMagic = @"/magic";

static NSString * const FWURLMessageRouter = @"/msgrouter";

@interface YXHttpClient (Message)
- (NSURLSessionDataTask *)sendMagicSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure;

- (NSURLSessionDataTask *)sendMessageRouterFrom:(NSString *)fromUid to:(NSString *)toUid message:(RCMessageContent *)aContent Success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure;
@end
