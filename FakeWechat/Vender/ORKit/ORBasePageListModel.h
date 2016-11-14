//
//  ORBasePageListModel.h
//  ORead
//
//  Created by noname on 14-8-2.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import "ORBaseListModel.h"

@interface ORBasePageListModel : ORBaseListModel
@property (nonatomic, readonly) BOOL hasFetched;    // 是否取过数据
@property (nonatomic, assign) NSInteger totalCount; // 总数

- (void)fetchMore;

- (void)asyncFetchListAtPage:(NSInteger)aPageIndex completion:(void (^)(BOOL isSuccess, NSArray *listArray,int count, int totalCount))completion;
@end
