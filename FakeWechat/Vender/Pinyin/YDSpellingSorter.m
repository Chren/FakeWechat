//
//  YDSpellingSorter.m
//  yxtk
//
//  Created by Aren on 15/10/10.
//  Copyright © 2015年 mac. All rights reserved.
//

#import "YDSpellingSorter.h"
#import "pinyin.h"

@interface YDSpellingSorter()
@property (strong, nonatomic) NSArray *keys;
@end

@implementation YDSpellingSorter
- (id)init {
    self = [super init];
    if (self) {
        _keys = @[@"↑", @"A",@"B",@"C",@"D",@"E",
                  @"F",@"G",@"H",@"I",@"J",
                  @"K",@"L",@"M",@"N",@"O",
                  @"P",@"Q",@"R",@"S",@"T",
                  @"U",@"V",@"W",@"X",@"Y",
                  @"Z",@"#"];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static YDSpellingSorter *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

/**
 *  按首字母排序
 *
 *  @param aDataSource 数据源
 *
 *  @return 返回排序后的字典
 */
- (NSMutableDictionary *)sortWithDataSource:(NSArray *)aDataSource
{
    if(!aDataSource) return nil;
    
    NSMutableDictionary *returnDic = [NSMutableDictionary new];
    NSMutableArray *tempOtherArr = [NSMutableArray new];
    BOOL isReturn = NO;
    
    for (NSString *key in _keys) {
        
        if ([tempOtherArr count]) {
            isReturn = YES;
        }
        
        NSMutableArray *tempArr = [NSMutableArray new];
        for (id<YDSpellingSorterProtocol> member in aDataSource) {
            
            NSString *sortKey = [member sortKey];
            NSString *firstLetter = [sortKey substringToIndex:1];
            if ([firstLetter isEqualToString:key]) {
                [tempArr addObject:member];
            }
            
            if(isReturn) continue;
            char c = [sortKey characterAtIndex:0];
            if (isalpha(c) == 0) {
                [tempOtherArr addObject:member];
            }
        }
        if(![tempArr count]) continue;
        [returnDic setObject:tempArr forKey:key];
    }
    
    if([tempOtherArr count]) {
        [returnDic setObject:tempOtherArr forKey:@"#"];
    }
    return returnDic;
}

@end
