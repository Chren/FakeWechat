//
//  DataUtil.h
//  GlassStore
//
//  Created by noname on 15/4/11.
//  Copyright (c) 2015年 ORead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataUtil : NSObject
/**
 *  从bundle读取假数据
 *
 *  @param aFileName json文件名
 *
 *  @return 返回解析后的object
 */
+ (NSObject *)loadFakeDataFromJsonFileName:(NSString *)aFileName;

+ (long long)userIdFromRCUserId:(NSString *)aUserid;
@end
