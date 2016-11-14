//
//  FWProposalMessage.m
//  FakeWechat
//
//  Created by Aren on 2016/11/10.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWProposalMessage.h"

static NSString * const RCLocalMessageTypeIdentifier = @"RC:ProposalMsg";

static NSString * const KEY_PROPOSALMSG_MSG = @"message";

@implementation FWProposalMessage
+ (instancetype)messageWithMsg:(NSString *)message
{
    FWProposalMessage *msg = [[FWProposalMessage alloc] init];
    if (msg) {
        msg.message = message;
    }
    return msg;
}

+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

#pragma mark - NSCoding protocol methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.message = [aDecoder decodeObjectForKey:KEY_PROPOSALMSG_MSG];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.message forKey:KEY_PROPOSALMSG_MSG];
}


#pragma mark - RCMessageCoding delegate methods
- (NSData *)encode
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    if (self.message) {
        [dataDict setObject:self.message forKey:KEY_PROPOSALMSG_MSG];
    }
    
    if (self.senderUserInfo) {
        NSMutableDictionary *__dic=[[NSMutableDictionary alloc]init];
        if (self.senderUserInfo.name) {
            [__dic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [__dic setObject:self.senderUserInfo.portraitUri forKeyedSubscript:@"icon"];
        }
        if (self.senderUserInfo.userId) {
            [__dic setObject:self.senderUserInfo.userId forKeyedSubscript:@"id"];
        }
        [dataDict setObject:__dic forKey:@"user"];
    }
    
    //NSDictionary* dataDict = [NSDictionary dictionaryWithObjectsAndKeys:self.content, @"content", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data
{
#if 1
    __autoreleasing NSError* __error = nil;
    if (!data) {
        return;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&__error];
#else
    NSString *jsonStream = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *json = [RCJSONConverter dictionaryWithJSONString:jsonStream];
#endif
    if (json) {
        self.message = json[KEY_PROPOSALMSG_MSG];
        NSObject *__object = [json objectForKey:@"user"];
        NSDictionary *userinfoDic = nil;
        if (__object &&[__object isMemberOfClass:[NSDictionary class]]) {
            userinfoDic = (NSDictionary *)__object;
        }
        if (userinfoDic) {
            RCUserInfo *userinfo =[RCUserInfo new];
            userinfo.userId = [userinfoDic objectForKey:@"id"];
            userinfo.name = [userinfoDic objectForKey:@"name"];
            userinfo.portraitUri = [userinfoDic objectForKey:@"icon"];
            self.senderUserInfo = userinfo;
        }
    }
}

- (NSString *)conversationDigest
{
    return @"[微信红包]";
}

+ (NSString *)getObjectName {
    return RCLocalMessageTypeIdentifier;
}
@end
