//
//  YXHttpClient.h
//  YXHttpClientDemo
//
//  Created by Aren on 16/7/20.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFSecurityPolicy.h"

typedef NS_OPTIONS(NSInteger, YXHttpType) {
    YXHttpTypeGet = 0,
    YXHttpTypePost
};

typedef NS_OPTIONS(NSInteger, YXCachePolicy) {
    /**
     *  不使用缓存
     */
    YXCachePolicyNoCache = 0,
    /**
     *  从缓存读取
     */
    YXCachePolicyForceCache = 1,
    /**
     *  先从缓存读取，再从网络请求读取，会回调两次
     */
    YXCachePolicyFirstCacheThenRequest = 2,
    
    YXCachePolicyUnknown
};


@class YXHttpClient;
@protocol YXHttpClientDataSource<NSObject>
@optional
/**
 *  用于设置自定义http请求头，每条请求都会调用一次
 *
 *  @param aClient YXHttpClient实例
 *  @param anUrl   请求url
 *
 *  @return 包含请求头的NSDictionary
 */
- (NSDictionary *)httpClient:(YXHttpClient *)aClient customHeaderForUrl:(NSString *)anUrl;

/**
 *  用于自定义解析返回结果
 *
 *  @param aClient   YXHttpClient实例
 *  @param aResopnse 原始返回包
 *
 *  @return 处理过的返回包
 */
- (id)httpClient:(YXHttpClient *)aClient customResponseFromOriginal:(id)aResopnse;
@end

@protocol YXHttpCacheDataSource<NSObject>
@optional
- (id)fetchCacheForUrl:(NSString *)anUrl param:(NSDictionary *)aDict;
- (void)saveCacheForUrl:(NSString *)anUrl param:(NSDictionary *)aDict cacheData:(id)aData;
@end

@interface YXHttpClient : NSObject
@property (weak, nonatomic) id<YXHttpClientDataSource> dataSource;
@property (weak, nonatomic) id<YXHttpCacheDataSource> cacheDataSource;
@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) AFSecurityPolicy *securityPolicy;

+ (instancetype)sharedClient;

/**
 *  发起一个http请求
 *
 *  @param anUrl    请求链接，如果已设置了baseUrl，则这里传相对路径
 *  @param aMethod  请求方法，YXHttpTypeGet，YXHttpTypePost
 *  @param aParam   请求参数
 *  @param aSuccess 成功回调
 *  @param aFailure 失败回调
 *
 *  @return task
 */
- (NSURLSessionDataTask *)performRequestWithUrl:(NSString *)anUrl
                   httpMethod:(YXHttpType)aMethod
                        param:(NSDictionary *)aParam
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure;

/**
 *  发起一个http请求
 *
 *  @param anUrl    请求链接，如果已设置了baseUrl，则这里传相对路径
 *  @param aMethod  请求方法，YXHttpTypeGet，YXHttpTypePost
 *  @param aParam   请求参数
 *  @param aSuccess 成功回调
 *  @param aFailure 失败回调
 *  @param aPoclicy 缓存策略
 *
 *  @return task
 */
- (NSURLSessionDataTask *)performRequestWithUrl:(NSString *)anUrl
                                     httpMethod:(YXHttpType)aMethod
                                          param:(NSDictionary *)aParam
                                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
                                   cachePoclicy:(YXCachePolicy)aPoclicy;

/**
 *  发起一个http请求
 *
 *  @param anUrl    请求链接，如果已设置了baseUrl，则这里传相对路径
 *  @param aMethod  请求方法，YXHttpTypeGet，YXHttpTypePost
 *  @param aParam   请求参数
 *  @param aSuccess 成功回调
 *  @param aFailure 失败回调
 *  @param aFailure 是否开启缓存
 *
 *  @return task
 */
- (NSURLSessionDataTask *)performRequestWithUrl:(NSString *)anUrl
                                     httpMethod:(YXHttpType)aMethod
                                          param:(NSDictionary *)aParam
                                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
                                    cacheEnable:(BOOL)isEnable;

/**
 *  发起下载请求
 *
 *  @param anUrl              请求链接
 *  @param aProgressBlock     下载进度回调
 *  @param aDestination       下载完成后保存路径
 *  @param aCompletionHandler 下载完成后回调
 *
 *  @return task
 */
- (NSURLSessionDownloadTask *)performDownloadRequestWithUrl:(NSString *)anUrl
                                                   progress:(void (^)(NSProgress *downloadProgress))aProgressBlock
                                                destination:(NSURL *(^)(NSURL *targetPath, NSURLResponse *response))aDestination
                                          completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))aCompletionHandler;


/**
 *  发起上传请求
 *
 *  @param anUrl          请求链接
 *  @param aFiles         文件列表
 *  @param aParam         参数
 *  @param aProgressBlock 上传进度回调
 *  @param aSuccess       上传成功回调
 *  @param aFailure       上传失败回调
 *
 *  @return task
 */
- (NSURLSessionDataTask *)performUploadRequestWithUrl:(NSString *)anUrl
                                                files:(NSArray *)aFiles
                                               parameters:(NSDictionary *)aParam
                                                 progress:(void (^)(NSProgress *uploadProgress))aProgressBlock
                                                  success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                                  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure;
@end
