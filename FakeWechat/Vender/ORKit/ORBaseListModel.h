//
//  ORBaseListModel.h
//  ORead
//
//  Created by noname on 14-8-2.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kKeyPathDataSource @"dataSource"
#define kKeyPathDataFetchResult @"dataFetchResult"
@interface ORBaseListModel : NSObject
@property (nonatomic, strong) id dataFetchResult;
@property (nonatomic, assign) BOOL hasMore;       // 是否有下一页数据
@property (nonatomic, assign) BOOL forceUseCache;
- (void)fetchList;
//access
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)count;
- (NSInteger)indexOfObject:(id)object;
- (id)lastObject;
// kvo
- (void)setArray:(NSArray *)array;
- (void)insertObject:(id)object atIndex:(NSUInteger)index;
- (void)insertDataSource:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)replaceObject:(id)object atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)addObjectsFromArray:(NSArray *)objects;
@end
