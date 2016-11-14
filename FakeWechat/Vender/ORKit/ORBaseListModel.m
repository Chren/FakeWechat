//
//  ORBaseListModel.m
//  ORead
//
//  Created by noname on 14-8-2.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import "ORBaseListModel.h"

@interface ORBaseListModel ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ORBaseListModel
- (id)init {
    self = [super init];
    if (self) {
        _dataSource = [[NSMutableArray alloc] init];
        _hasMore = NO;
    }
    return self;
}
#pragma mark access method
- (id)objectAtIndex:(NSUInteger)index
{
    return [self.dataSource objectAtIndex:index];
}

- (NSUInteger)count
{
    return [self.dataSource count];
}

- (NSInteger)indexOfObject:(id)object
{
    return [self.dataSource indexOfObject:object];
}

- (id)lastObject
{
    return [self.dataSource lastObject];
}

- (void)fetchList
{
    
}

#pragma mark kvo
- (void)setArray:(NSArray *)array
{
    if (array)
    {
        self.dataSource = [NSMutableArray arrayWithArray:array];
    }
    else
    {
        self.dataSource = nil;
    }
}

- (void)insertDataSource:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"dataSource"];
    [self.dataSource insertObjects:array atIndexes:indexes];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"dataSource"];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
    NSMutableArray *KVCArray = [self mutableArrayValueForKey:@"dataSource"];
    [KVCArray insertObject:object atIndex:index];
}

- (void)replaceObject:(id)object atIndex:(NSUInteger)index
{
    NSMutableArray *KVCArray = [self mutableArrayValueForKey:@"dataSource"];
    [KVCArray replaceObjectAtIndex:index withObject:object];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    NSMutableArray *KVCArray = [self mutableArrayValueForKey:@"dataSource"];
    [KVCArray removeObjectAtIndex:index];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *KVCArray = [self mutableArrayValueForKey:@"dataSource"];
    [KVCArray removeObjectsAtIndexes:indexes];
}

- (void)addObjectsFromArray:(NSArray *)objects
{
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.dataSource count], [objects count])] forKey:@"dataSource"];
    [self.dataSource addObjectsFromArray:objects];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.dataSource count], [objects count])] forKey:@"dataSource"];
    //    [self.dataSource addObjectsFromArray:objects];
    //    NSMutableArray *KVCArray = [self mutableArrayValueForKey:@"dataSource"];
    //    [KVCArray addObjectsFromArray:objects];
}

@end
