//
//  YXHttpClient.m
//  YXHttpClientDemo
//
//  Created by Aren on 16/7/20.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "YXHttpClient.h"
#import "AFHTTPSessionManager.h"

@interface YXHttpClient()
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@end
@implementation YXHttpClient
+ (instancetype)sharedClient
{
    static YXHttpClient *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[YXHttpClient alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sessionManager = [AFHTTPSessionManager manager];
    }
    return self;
}

- (void)setBaseUrl:(NSString *)aBaseUrl
{
    if (_baseUrl && [_baseUrl isEqualToString:aBaseUrl]) {
        return;
    } else {
        _baseUrl = aBaseUrl;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_baseUrl]];
    }
}

- (void)setSecurityPolicy:(AFSecurityPolicy *)aPolicy
{
    if (_securityPolicy!=aPolicy) {
        _securityPolicy = aPolicy;
        _sessionManager.securityPolicy = aPolicy;
    }
}

- (void)addCustomHeaderForUrl:(NSString *)anUrl
{
    if ([self.dataSource respondsToSelector:@selector(httpClient:customHeaderForUrl:)]) {
        NSDictionary *dict = [self.dataSource httpClient:self customHeaderForUrl:anUrl];
        for (NSString *key in dict) {
            [self.sessionManager.requestSerializer setValue:dict[key] forHTTPHeaderField:key];
        }
    }
}

- (NSURLSessionDataTask *)performRequestWithUrl:(NSString *)anUrl
                   httpMethod:(YXHttpType)aMethod
                        param:(NSDictionary *)aParam
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
{
    return [self performRequestWithUrl:anUrl httpMethod:aMethod param:aParam success:aSuccess failure:aFailure cachePoclicy:YXCachePolicyNoCache];
}

- (NSURLSessionDataTask *)performRequestWithUrl:(NSString *)anUrl
                                     httpMethod:(YXHttpType)aMethod
                                          param:(NSDictionary *)aParam
                                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
                                   cachePoclicy:(YXCachePolicy)aPoclicy
{
    if (aPoclicy == YXCachePolicyNoCache) {
        [self addCustomHeaderForUrl:anUrl];
        if (aMethod == YXHttpTypeGet) {
            NSURLSessionDataTask *task = [self.sessionManager GET:anUrl parameters:aParam success:^(NSURLSessionDataTask * task, id responseObject) {
                if (aSuccess) {
                    if ([self.dataSource respondsToSelector:@selector(httpClient:customResponseFromOriginal:)]) {
                        id newResponse = [self.dataSource httpClient:self customResponseFromOriginal:responseObject];
                        aSuccess(task, newResponse);
                    } else {
                        aSuccess(task, responseObject);
                    }
                    [self setCache:responseObject forUrl:anUrl param:aParam];
                }
            } failure:^(NSURLSessionDataTask * task, NSError * error) {
                if (aFailure) {
                    aFailure(task, error);
                }
            }];
            return task;
        } else if (aMethod == YXHttpTypePost) {
            NSURLSessionDataTask *task = [self.sessionManager POST:anUrl parameters:aParam success:^(NSURLSessionDataTask * task, id responseObject) {
                if (aSuccess) {
                    if ([self.dataSource respondsToSelector:@selector(httpClient:customResponseFromOriginal:)]) {
                        id newResponse = [self.dataSource httpClient:self customResponseFromOriginal:responseObject];
                        aSuccess(task, newResponse);
                    } else {
                        aSuccess(task, responseObject);
                    }
                    [self setCache:responseObject forUrl:anUrl param:aParam];
                }
            } failure:^(NSURLSessionDataTask * task, NSError * error) {
                if (aFailure) {
                    aFailure(task, error);
                }
            }];
            return task;
        }
        return nil;
    } else if (aPoclicy == YXCachePolicyForceCache) {
        if ([self.cacheDataSource respondsToSelector:@selector(fetchCacheForUrl:param:)]) {
            id response = [self.cacheDataSource fetchCacheForUrl:anUrl param:aParam];
            if (aSuccess && response) {
                if ([self.dataSource respondsToSelector:@selector(httpClient:customResponseFromOriginal:)]) {
                    id newResponse = [self.dataSource httpClient:self customResponseFromOriginal:response];
                    aSuccess(nil, newResponse);
                } else {
                    aSuccess(nil, response);
                }
            } else {
                aFailure(nil, nil);
            }
        } else {
            if (aFailure) {
                aFailure(nil, nil);
            }
        }
        return nil;
    } else if (aPoclicy == YXCachePolicyFirstCacheThenRequest) {
        if ([self.cacheDataSource respondsToSelector:@selector(fetchCacheForUrl:param:)]) {
            id response = [self.cacheDataSource fetchCacheForUrl:anUrl param:aParam];
            if (aSuccess && response) {
                if ([self.dataSource respondsToSelector:@selector(httpClient:customResponseFromOriginal:)]) {
                    id newResponse = [self.dataSource httpClient:self customResponseFromOriginal:response];
                    aSuccess(nil, newResponse);
                } else {
                    aSuccess(nil, response);
                }
            }
        }
        
        [self performRequestWithUrl:anUrl httpMethod:aMethod param:aParam success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([self.dataSource respondsToSelector:@selector(httpClient:customResponseFromOriginal:)]) {
                id newResponse = [self.dataSource httpClient:self customResponseFromOriginal:responseObject];
                aSuccess(nil, newResponse);
            } else {
                aSuccess(nil, responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (aFailure) {
                aFailure(task, error);
            }
        } cachePoclicy:YXCachePolicyNoCache];

        return nil;
    } else {
        return nil;
    }
}

- (NSURLSessionDataTask *)performRequestWithUrl:(NSString *)anUrl
                                     httpMethod:(YXHttpType)aMethod
                                          param:(NSDictionary *)aParam
                                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
                                    cacheEnable:(BOOL)isEnable
{
    if (isEnable) {
        if ([self.cacheDataSource respondsToSelector:@selector(fetchCacheForUrl:param:)]) {
            id response = [self.cacheDataSource fetchCacheForUrl:anUrl param:aParam];
            if (aSuccess && response) {
                aSuccess(nil, response);
            }
            [self performRequestWithUrl:anUrl httpMethod:aMethod param:aParam success:^(NSURLSessionDataTask *task, id responseObject) {
                if (aSuccess) {
                    aSuccess(task, responseObject);
                }
                [self setCache:responseObject forUrl:anUrl param:aParam];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (aFailure) {
                    aFailure(task, error);
                }
            }];
        }
        return nil;
    } else {
        [self addCustomHeaderForUrl:anUrl];
        if (aMethod == YXHttpTypeGet) {
            NSURLSessionDataTask *task = [self.sessionManager GET:anUrl parameters:aParam success:^(NSURLSessionDataTask * task, id responseObject) {
                if (aSuccess) {
                    if ([self.dataSource respondsToSelector:@selector(httpClient:customResponseFromOriginal:)]) {
                        id newResponse = [self.dataSource httpClient:self customResponseFromOriginal:responseObject];
                        aSuccess(task, newResponse);
                    } else {
                        aSuccess(task, responseObject);
                    }
                }
            } failure:^(NSURLSessionDataTask * task, NSError * error) {
                if (aFailure) {
                    aFailure(task, error);
                }
            }];
            return task;
        } else if (aMethod == YXHttpTypePost) {
            NSURLSessionDataTask *task = [self.sessionManager POST:anUrl parameters:aParam success:^(NSURLSessionDataTask * task, id responseObject) {
                if (aSuccess) {
                    if ([self.dataSource respondsToSelector:@selector(httpClient:customResponseFromOriginal:)]) {
                        id newResponse = [self.dataSource httpClient:self customResponseFromOriginal:responseObject];
                        aSuccess(task, newResponse);
                    } else {
                        aSuccess(task, responseObject);
                    }
                }
            } failure:^(NSURLSessionDataTask * task, NSError * error) {
                if (aFailure) {
                    aFailure(task, error);
                }
            }];
            return task;
        }
        return nil;
    }
}

- (NSURLSessionDownloadTask *)performDownloadRequestWithUrl:(NSString *)anUrl
                                                   progress:(void (^)(NSProgress *downloadProgress))aProgressBlock
                                                destination:(NSURL *(^)(NSURL *targetPath, NSURLResponse *response))aDestination
                                          completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))aCompletionHandler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:anUrl]];
    NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (aProgressBlock) {
            aProgressBlock(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (aDestination) {
            return aDestination(targetPath, response);
        } else {
            NSString *path = NSTemporaryDirectory();
            path = [path stringByAppendingPathComponent:[anUrl lastPathComponent]];
            return [NSURL fileURLWithPath:path];
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (aCompletionHandler) {
            aCompletionHandler(response, filePath, error);
        }
    }];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)performUploadRequestWithUrl:(NSString *)anUrl
                                                files:(NSArray *)aFiles
                                           parameters:(NSDictionary *)aParam
                                             progress:(void (^)(NSProgress *uploadProgress))aProgressBlock
                                              success:(void (^)(NSURLSessionDataTask *task, id responseObject))aSuccess
                                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))aFailure
{
    NSURLSessionDataTask *task = [self.sessionManager POST:anUrl parameters:aParam constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (id file in aFiles) {
            if ([file isKindOfClass:[UIImage class]]) {
                NSData *data = UIImagePNGRepresentation(file);
                [formData appendPartWithFileData:data name:@"file" fileName:@"image.png" mimeType:@"image/png"];
            } else if ([file isKindOfClass:[NSString class]]) {
                NSError *error = nil;
                [formData appendPartWithFileURL:[NSURL URLWithString:file] name:@"file" error:&error];
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (aProgressBlock) {
            aProgressBlock(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (aSuccess) {
            aSuccess(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (aFailure) {
            aFailure(task, error);
        }
    }];
    return task;
}

#pragma mark - Private Method
- (id)getCacheForUrl:(NSString *)anUrl param:(NSDictionary *)aParam
{
    if ([self.cacheDataSource respondsToSelector:@selector(fetchCacheForUrl:param:)]) {
        return [self.cacheDataSource fetchCacheForUrl:anUrl param:aParam];
    }
    return nil;
}

- (void)setCache:(id)aData forUrl:(NSString *)anUrl param:(NSDictionary *)aParam
{
    if ([self.cacheDataSource respondsToSelector:@selector(saveCacheForUrl:param:cacheData:)]) {
        [self.cacheDataSource saveCacheForUrl:anUrl param:aParam cacheData:aData];
    }
}

@end
