//
//  FWAddressBookListModel.m
//  FakeWechat
//
//  Created by Aren on 2016/10/23.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWAddressBookListModel.h"
#import "pinyin.h"
#import "FWSession.h"

@interface FWAddressBookListModel()
@property (strong, nonatomic) NSArray *keys;
@property (strong, nonatomic) NSArray *fullContactList;
@property (strong, nonatomic) NSMutableArray *selectedFriends;
@end

@implementation FWAddressBookListModel
- (id)init {
    self = [super init];
    if (self) {
        self.allFriends = [[NSMutableDictionary alloc] init];
        [[[FWSession shareInstance] friendListModel] addObserver:self forKeyPath:kKeyPathDataSource options:NSKeyValueObservingOptionNew context:nil];
        [self constructContactList];
        _keys = @[kAddressBookSystemKey, @"A",@"B",@"C",@"D",@"E",
                  @"F",@"G",@"H",@"I",@"J",
                  @"K",@"L",@"M",@"N",@"O",
                  @"P",@"Q",@"R",@"S",@"T",
                  @"U",@"V",@"W",@"X",@"Y",
                  @"Z",@"#"];
        _selectedFriends = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)constructContactList
{
    self.fullContactList = [[FWSession shareInstance].friendListModel getArray];
    NSMutableArray *allKeysArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *contactDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dict = [self sortedArrayWithPinYinDic:self.fullContactList];
    
    NSArray *tempArray = [[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    [allKeysArray addObjectsFromArray:tempArray];
    [contactDict setDictionary:dict];
    
    if (self.showSystem) {
        NSArray *systemCellArray = @[@{@"name":@"新的朋友", @"type":@(1), @"imgName":@"plugins_FriendNotify"},
                                     @{@"name":@"群聊", @"type":@(1), @"imgName":@"add_friend_icon_addgroup"},
                                     @{@"name":@"标签", @"type":@(1), @"imgName":@"Contact_icon_ContactTag"},
                                     @{@"name":@"公众号", @"type":@(1), @"imgName":@"add_friend_icon_offical"}];
        NSMutableArray *systemArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in systemCellArray) {
            NSError *error = nil;
            FWAddressSystemCellInfo *cellInfo = [[FWAddressSystemCellInfo alloc] initWithDictionary:dict error:&error];
            [systemArray addObject:cellInfo];
        }
        [allKeysArray insertObject:kAddressBookSystemKey atIndex:0];
        [contactDict setObject:systemArray forKey:kAddressBookSystemKey];
    }
    self.allKeys = allKeysArray;
    self.allFriends = contactDict;
}

- (void)dealloc
{
    [[[FWSession shareInstance] friendListModel] removeObserver:self forKeyPath:kKeyPathDataSource];
}
#pragma mark - 拼音排序

/**
 *  汉字转拼音
 *
 *  @param hanZi 汉字
 *
 *  @return 转换后的拼音
 */
-(NSString *) hanZiToPinYinWithString:(NSString *)hanZi
{
    if(!hanZi) return nil;
    NSString *pinYinResult = [NSString string];
    for(int j=0; j<hanZi.length; j++){
        NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c", pinyinFirstLetter([hanZi characterAtIndex:j])] uppercaseString];
        pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
    }
    
    return pinYinResult;
}

/**
 *  根据转换拼音后的字典排序
 *
 *  @param friends 转换后的字典
 *
 *  @return 对应排序的字典
 */
- (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)friends
{
    if(!friends) return nil;
    
    NSMutableDictionary *returnDic = [NSMutableDictionary new];
    NSMutableArray *tempOtherArr = [NSMutableArray new];
    BOOL isReturn = NO;
    
    for (NSString *key in _keys) {
        
        if ([tempOtherArr count]) {
            isReturn = YES;
        }
        
        NSMutableArray *tempArr = [NSMutableArray new];
        for (FWUserModel *user in friends) {
            NSString *pyResult = [self hanZiToPinYinWithString:user.name];
            user.pinyinname = pyResult;
            NSString *firstLetter = [pyResult substringToIndex:1];
            if ([firstLetter isEqualToString:key]){
                [tempArr addObject:user];
            }
            
            if(isReturn) continue;
            char c = [pyResult characterAtIndex:0];
            if (isalpha(c) == 0) {
                [tempOtherArr addObject:user];
            }
        }
        if(![tempArr count]) continue;
        [returnDic setObject:tempArr forKey:key];
    }
    if([tempOtherArr count])
        [returnDic setObject:tempOtherArr forKey:@"#"];
    return returnDic;
}

#pragma mark - 外部接口
- (void)searchWithKeyword:(NSString *)aKeyword
{
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:aKeyword];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    long long uid = 0;
    if (valid) {
        uid = [aKeyword longLongValue];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pinyinname CONTAINS[cd] %@ or phone CONTAINS[cd] %@ or nickname CONTAINS[cd] %@ or fuserid == %lld", aKeyword, aKeyword, aKeyword, uid];
    
    NSArray *tempArray = [self.fullContactList filteredArrayUsingPredicate:predicate];
    if (tempArray.count > 0) {
        self.filteredFriends = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            FWUserModel *userInfo1 = obj1;
            FWUserModel *userInfo2 = obj2;
            return [userInfo1.pinyinname compare:userInfo2.pinyinname options:NSNumericSearch];
        }];
    } else {
        self.filteredFriends = nil;
    }
}

- (void)selectUserWithUserInfo:(FWUserModel *)aUserInfo
{
    for (int i=0; i<self.selectedFriends.count; i++) {
        FWUserModel *userInfo =  [self.selectedFriends objectAtIndex:i];
        if (userInfo.userid == aUserInfo.userid) {
            [self.selectedFriends replaceObjectAtIndex:i withObject:aUserInfo];
            return;
        }
    }
    [self.selectedFriends addObject:aUserInfo];
}

- (void)deselectUserWithUserInfo:(FWUserModel *)aUserInfo
{
    for (int i=0; i<self.selectedFriends.count; i++) {
        FWUserModel *userInfo =  [self.selectedFriends objectAtIndex:i];
        if (userInfo.userid == aUserInfo.userid) {
            [self.selectedFriends removeObjectAtIndex:i];
            return;
        }
    }
    
    for (int i=0; i<self.preselectedFriends.count; i++) {
        NSString *uid =  [self.preselectedFriends objectAtIndex:i];
        if (uid.longLongValue == aUserInfo.userid) {
            [self.preselectedFriends removeObjectAtIndex:i];
            return;
        }
    }
}

- (void)deselectAllUsers
{
    [self.selectedFriends removeAllObjects];
}

- (BOOL)isSelectWithUserInfo:(FWUserModel *)aUserInfo
{
    for (int i=0; i<self.selectedFriends.count; i++) {
        FWUserModel *userInfo =  [self.selectedFriends objectAtIndex:i];
        if (userInfo.userid == aUserInfo.userid) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isPreSelectWithUserInfo:(FWUserModel *)aUserInfo
{
    for (int i=0; i<self.preselectedFriends.count; i++) {
        NSString *uid =  [self.preselectedFriends objectAtIndex:i];
        if (uid.longLongValue == aUserInfo.userid) {
            return YES;
        }
    }
    return NO;
}
//- (NSInteger)indexOfUserInfo:(YDBaseUserInfo *)aUserInfo
//{
//    int a = self.allFriends
//}
- (FWUserModel *)userinfoWithUid:(long long)aUid
{
    for (FWUserModel *friendInfo in self.fullContactList) {
        if (friendInfo.userid == aUid) {
            return friendInfo;
        }
    }
    return nil;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kKeyPathDataSource]) {
        [self constructContactList];
    }
}

@end
