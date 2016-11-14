//
//  FWErrorDef.h
//  FakeWechat
//
//  Created by Aren on 2016/10/27.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, FWErrorCode) {
    // 通用错误码Common
    FWErrorCMSuccess = 200,
    /**
     *  设备未注册
     */
    FWErrorInvalidDevice = 505,
    /**
     *  token非法或失效
     */
    FWErrorCMInvalidToken = 418,
    /**
     *  token为空   登录页面
     */
    FWErrorCMEmptyToken = 417,
    
};

