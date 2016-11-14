//
//  YDSpellingSorter.h
//  yxtk
//
//  Created by Aren on 15/10/10.
//  Copyright © 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YDSpellingSorterProtocol <NSObject>

- (NSString *)sortKey;

@end


@interface YDSpellingSorter : NSObject
+ (YDSpellingSorter *)sharedInstance;

- (NSMutableDictionary *)sortWithDataSource:(NSArray *)aDataSource;
@end
