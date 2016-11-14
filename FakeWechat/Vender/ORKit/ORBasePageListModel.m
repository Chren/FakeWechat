//
//  ORBasePageListModel.m
//  ORead
//
//  Created by noname on 14-8-2.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import "ORBasePageListModel.h"

@implementation ORBasePageListModel
{
    NSInteger _pageIndex;
    NSInteger _curFetchIndex;
}

- (void)_reset
{
    _curFetchIndex = -1;
    _pageIndex = 0;
    self.hasMore = NO;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _reset];
    }
    return self;
}

- (void)fetchList
{
    [self _reset];
    [self _fetchListAtPageIndex:_pageIndex];
}

- (void)fetchMore
{
    if (self.hasMore)
    {
        [self _fetchListAtPageIndex:_pageIndex+1];
    }
}

- (void)_fetchListAtPageIndex:(NSInteger)aPageIndex
{
    if (aPageIndex <= _curFetchIndex)
    {
        return;
    }
    
    _curFetchIndex = aPageIndex;
    
    [self asyncFetchListAtPage:aPageIndex completion:^(BOOL isSuccess, NSArray *listArray, int count, int totalCount) {
        if (isSuccess)
        {
            _hasFetched = YES;
            _pageIndex = aPageIndex;
            if (totalCount <= count * (_pageIndex + 1) || listArray.count == 0)
            {
                self.hasMore = NO;
            }
            else
            {
                self.hasMore = YES;
            }
            [self setTotalCount:totalCount];
            
            if (_pageIndex == 0)
            {
                if (listArray) {
                    [self setArray:listArray];
                } else {
                    [self setArray:[[NSMutableArray alloc] init]];
                }
                
            }
            else
            {
                [self addObjectsFromArray:listArray];
            }
        }
        else
        {
            _curFetchIndex = aPageIndex-1;
        }
    }];
}

- (void)asyncFetchListAtPage:(NSInteger)aPageIndex completion:(void (^)(BOOL isSuccess, NSArray *listArray, int count, int totalCount))completion
{
    NSAssert(0, @"子类需要重写该函数");
}

@end
