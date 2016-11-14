//
//  FWAddressBookListModel.h
//  FakeWechat
//
//  Created by Aren on 2016/10/23.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORBaseModel.h"
#import "FWBaseJSONModel.h"
#import "FWAddressSystemCellInfo.h"

static NSString * const kKeyPathForAllFriends = @"allFriends";
static NSString * const kKeyPathForFilteredFriends = @"filteredFriends";
static NSString * const kKeyPathForAllKeys = @"allKeys";
static NSString * const kAddressBookSystemKey = @"↑";

@interface FWAddressBookListModel : ORBaseModel
@property (strong, nonatomic) NSMutableDictionary *allFriends;
@property (strong, nonatomic) NSArray *allKeys;
@property (strong, nonatomic) NSArray *filteredFriends;
@property (readonly, nonatomic) NSMutableArray *selectedFriends;
@property (strong, nonatomic) NSMutableArray *preselectedFriends;
@property (assign, nonatomic) BOOL showSystem;

- (void)constructContactList;
@end
