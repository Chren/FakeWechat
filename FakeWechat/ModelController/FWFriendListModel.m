//
//  FWFriendListModel.m
//  FakeWechat
//
//  Created by Aren on 2016/10/28.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWFriendListModel.h"
#import "YXHttpClient+Account.h"
#import "FWErrorDef.h"
#import "FWBaseResponseModel.h"
#import "FWUserModel.h"

@interface FWFriendListModel()
@property (nonatomic, strong) NSMutableArray *dataSource;
@end
@implementation FWFriendListModel
- (id)init {
    self = [super init];
    if (self) {
        _dataSource = [[NSMutableArray alloc] init];
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

- (NSArray *)getArray
{
    return [NSArray arrayWithArray:self.dataSource];
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
}

- (void)fetchList
{
    [[YXHttpClient sharedClient] getFriendListWithSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        FWBaseResponseModel *response = (FWBaseResponseModel *)responseObject;
        if (response.errorcode == FWErrorCMSuccess) {
            NSError *error = nil;
            FWFriendList *data = [[FWFriendList alloc] initWithDictionary:response.data error:&error];
            [self setArray:data.result];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (FWUserModel *)userInfoWithUserid:(long long)aUserId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userid ==[c] %ld", aUserId];
    NSArray *filtered = [self.dataSource filteredArrayUsingPredicate:predicate];
    
    if (filtered.count > 0) {
        FWUserModel *userInfo = [filtered firstObject];
        return userInfo;
    }
    return nil;
}
@end
