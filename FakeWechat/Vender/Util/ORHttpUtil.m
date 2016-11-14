//
//  ORHttpUtil.m
//  PatientClient
//
//  Created by Aren on 16/3/11.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "ORHttpUtil.h"

@implementation ORHttpUtil
+ (NSDictionary *)paramsFromUrl:(NSURL *)anUrl
{
    NSString *paramStr = [anUrl query];
    NSArray *keyValueArray = [paramStr componentsSeparatedByString:@"&"];
    if (keyValueArray.count > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        for (NSString *keyValuePair in keyValueArray) {
            NSArray *array = [keyValuePair componentsSeparatedByString:@"="];
            if (array.count > 1) {
                [dict setObject:[array lastObject] forKey:[array firstObject]];
            }
        }
        return dict;
    } else {
        return nil;
    }
}
@end
