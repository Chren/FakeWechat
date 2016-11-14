//
//  YDCacheDataSource.h
//  yxtk
//
//  Created by Aren on 16/9/23.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXHttpClient.h"

@interface YDCacheDataSource : NSObject<YXHttpCacheDataSource>

- (nullable instancetype)initWithName:(nonnull NSString *)name;

- (nullable instancetype)initWithPath:(nonnull NSString *)path;

- (void)clearCache;
@end
