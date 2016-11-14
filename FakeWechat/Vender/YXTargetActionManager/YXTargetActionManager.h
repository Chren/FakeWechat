//
//  YXTargetActionManager.h
//  yxtk
//
//  Created by Aren on 16/7/14.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXTargetActionManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  本地组件调用入口
 *
 *  @param aTargetName  target名称
 *  @param anActionName action名称
 *  @param aParams      参数
 *
 *  @return 返回对应的viewcontroller等，具体由target来决定
 */
- (id)performTarget:(NSString *)aTargetName action:(NSString *)anActionName params:(NSDictionary *)aParams;
@end
