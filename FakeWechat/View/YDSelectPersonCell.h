//
//  YDSelectPersonCell.h
//  yxtk
//
//  Created by Aren on 15/6/18.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "ORBaseTableViewCell.h"
#import "M13BadgeView.h"

@class YDBaseUserInfo;
@interface YDSelectPersonCell : ORBaseTableViewCell
@property (strong, nonatomic) id userInfo;
@property (assign, nonatomic) BOOL showSelection;
@property (weak, nonatomic) IBOutlet M13BadgeView *badgeView;
@property (assign, nonatomic) BOOL preSelected;
- (void)bindWithData:(id)aUserInfo;
@end
