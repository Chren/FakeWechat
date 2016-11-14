//
//  YDCacheDataSource.m
//  yxtk
//
//  Created by Aren on 16/9/23.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "YDCacheDataSource.h"
#import "SecurityUtil.h"

#import <YYCache/YYCache.h>
@interface YDCacheDataSource ()
{
    dispatch_queue_t _queue;
}
@property YYCache *cache;
@end

@implementation YDCacheDataSource
- (nullable instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _cache = [[YYCache alloc] initWithName:name];
         [self commonInit];
    }
    return self;
}

- (nullable instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _cache = [[YYCache alloc] initWithPath:path];
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _queue = dispatch_queue_create("com.readyidu.yxtk.disk", DISPATCH_QUEUE_CONCURRENT);
}

- (id)fetchCacheForUrl:(NSString *)anUrl param:(NSDictionary *)aDict
{
    NSString *jsonStr = nil;
    NSString *fullUrl = nil;

    jsonStr = [SecurityUtil queryStringFromParameters:aDict];
    
    if (jsonStr.length > 0)
    {
        fullUrl = [[NSString alloc] initWithFormat:@"%@?%@", anUrl, jsonStr];
    } else {
        fullUrl = anUrl;
    }
    
    NSString *cacheKey = [fullUrl MD5];
    id cacheData = [self.cache objectForKey:cacheKey];
    return cacheData;
}

- (void)saveCacheForUrl:(NSString *)anUrl param:(NSDictionary *)aDict cacheData:(id)aData
{
    NSString *jsonStr = nil;
    NSString *fullUrl = nil;
    jsonStr = [SecurityUtil queryStringFromParameters:aDict];
    if (jsonStr.length > 0)
    {
        fullUrl = [[NSString alloc] initWithFormat:@"%@?%@", anUrl, jsonStr];
    } else {
        fullUrl = anUrl;
    }
    
    NSString *cacheKey = [fullUrl MD5];
    [self.cache setObject:aData forKey:cacheKey];
}

- (void)clearCache
{
    [self.cache removeAllObjects];
}
@end
