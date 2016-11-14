//
//  FWDataEngine.h
//  FakeWechat
//
//  Created by Aren on 2016/10/27.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const RONGCLOUD_IM_APPKEY = @"你的融云appkey";

@interface FWDataEngine : NSObject
+ (instancetype)shareInstance;
@end
