//
//  YDPinyinConverter.m
//  yxtk
//
//  Created by Aren on 15/10/10.
//  Copyright © 2015年 mac. All rights reserved.
//

#import "YDPinyinConverter.h"
#import "pinyin.h"

@implementation YDPinyinConverter

+ (NSString *) hanZiToPinYinWithString:(NSString *)aString
{
    if(!aString) return nil;
    NSString *pinYinResult = [NSString string];
    for(int j=0; j<aString.length; j++){
        NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c", pinyinFirstLetter([aString characterAtIndex:j])] uppercaseString];
        pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
    }
    
    return pinYinResult;
}
@end
