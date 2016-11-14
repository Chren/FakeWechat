//
//  DataUtil.m
//  GlassStore
//
//  Created by noname on 15/4/11.
//  Copyright (c) 2015年 ORead. All rights reserved.
//

#import "DataUtil.h"

@implementation DataUtil
+ (NSObject *)loadFakeDataFromJsonFileName:(NSString *)aFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:aFileName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSObject *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return jsonObject;
}

+ (long long)userIdFromRCUserId:(NSString *)aUserid
{
    NSArray *array = [aUserid componentsSeparatedByString:@"_"];
    if (array.count > 1) {
        NSString *longUserId = [array lastObject];
        return longUserId.longLongValue;
    }
    return 0;
}
@end
