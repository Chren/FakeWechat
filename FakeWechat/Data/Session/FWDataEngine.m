//
//  FWDataEngine.m
//  FakeWechat
//
//  Created by Aren on 2016/10/27.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWDataEngine.h"
#import "YXHttpClient.h"
#import "FWSession.h"
#import "FWBaseResponseModel.h"
#import "FWErrorDef.h"
#import "YDCacheDataSource.h"

#ifdef DEVSERVER
static NSString * const FWBaseURL = @"http://127.0.0.1:8000";
#else
static NSString * const FWBaseURL = @"http://120.26.62.120:8099";
#endif

static NSString * const kKeyHttpHeaderToken = @"token";

@interface FWDataEngine()
<YXHttpClientDataSource>
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *aesKey;
@property (strong, nonatomic) YDCacheDataSource *cacheDataSource;
@end

@implementation FWDataEngine
+ (instancetype)shareInstance
{
    static FWDataEngine *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[[self class] alloc] init];
        
    });
    return _shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initHttpClient];
    }
    return self;
}

- (void)_initHttpClient
{
    [[YXHttpClient sharedClient] setDataSource:self];
    [[YXHttpClient sharedClient] setBaseUrl:FWBaseURL];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    [securityPolicy setValidatesDomainName:NO];
    [securityPolicy setAllowInvalidCertificates:YES];
    _cacheDataSource = [[YDCacheDataSource alloc] initWithName:@"httpCache"];
    [[YXHttpClient sharedClient] setCacheDataSource:_cacheDataSource];
}

#pragma mark - YXHttpClient DataSource
- (NSDictionary *)httpClient:(YXHttpClient *)aClient customHeaderForUrl:(NSString *)anUrl
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    NSString *token = [FWSession shareInstance].sessionInfo.token;
    
    if (token.length > 0) {
        [dict setObject:token forKey:kKeyHttpHeaderToken];
    }
    
    return dict;
}

- (id)httpClient:(YXHttpClient *)aClient customResponseFromOriginal:(id)aResopnse
{
    NSError *error = nil;
    FWBaseResponseModel *response = aResopnse;
    if ([aResopnse isKindOfClass:[NSError class]]) {
        NSError *responseError = aResopnse;
        response = [FWBaseResponseModel new];
        response.errorcode = responseError.code;
        response.errormsg = responseError.localizedDescription;
    } else if ([aResopnse isKindOfClass:[NSDictionary class]]){
        response = [[FWBaseResponseModel alloc] initWithDictionary:aResopnse error:&error];
        if (response.errorcode == FWErrorCMInvalidToken || response.errorcode == FWErrorCMEmptyToken) {
            if ([FWSession shareInstance].isLogin) {
                [[FWSession shareInstance] logout];
            }
        } else if (response.errorcode == FWErrorInvalidDevice) {
            if ([FWSession shareInstance].isLogin) {
                [[FWSession shareInstance] logout];
            }
//            [self registerDevice];
        }
    }
    return response;
}
@end
