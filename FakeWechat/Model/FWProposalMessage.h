//
//  FWProposalMessage.h
//  FakeWechat
//
//  Created by Aren on 2016/11/10.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface FWProposalMessage : RCMessageContent
@property (strong, nonatomic) NSString *message;
+ (instancetype)messageWithMsg:(NSString *)message;
@end
