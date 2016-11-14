//
//  YDSelectPersonCell.m
//  yxtk
//
//  Created by Aren on 15/6/18.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "YDSelectPersonCell.h"
#import "FWUserModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ORColorUtil.h"
#import "FWAddressSystemCellInfo.h"
#import "FWDataEngine.h"
#import "ViewUtil.h"

@interface YDSelectPersonCell()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;


@end

@implementation YDSelectPersonCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = 2.5;
    self.avatarImageView.layer.masksToBounds = YES;
    self.badgeView.animateChanges = NO;
    self.badgeView.hidesWhenZero = YES;
    self.badgeView.font = [UIFont systemFontOfSize:12];
    self.badgeView.badgeBackgroundColor = ORColor(@"ff3131");
    self.badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentNone;
    self.badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentNone;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        if (self.preSelected) {
            self.selectedImageView.image = [UIImage imageNamed:@"btn_public_checker_disabled"];
        } else {
            self.selectedImageView.image = [UIImage imageNamed:@"btn_contact_check_highlight"];
        }
    }else{
        self.selectedImageView.image = [UIImage imageNamed:@"btn_contact_check_normal"];
    }
}

-(void)setShowSelection:(BOOL)showSelection
{
    _showSelection = showSelection;
    self.selectedImageView.hidden = !showSelection;
}

- (void)bindWithData:(id)aUserInfo
{
    self.userInfo = aUserInfo;
    if ([aUserInfo isKindOfClass:[FWUserModel class]]) {
        FWUserModel *userInfo = (FWUserModel *)aUserInfo;

        self.userNameLabel.text = userInfo.name;
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.photo] placeholderImage:[UIImage imageNamed:@"DefaultHead"]];
        self.badgeView.text = @"0";
    } else if ([aUserInfo isKindOfClass:[FWAddressSystemCellInfo class]]) {
        FWAddressSystemCellInfo *cellInfo = (FWAddressSystemCellInfo *)aUserInfo;
        self.userNameLabel.text = cellInfo.name;
        self.avatarImageView.image = [UIImage imageNamed:cellInfo.imgName];
        self.avatarImageView.layer.borderWidth = 0;
//        self.badgeView.text = [NSString stringWithFormat:@"%ld", (long)[GSDataEngine shareEngine].unreadFriendRequestCount];
    }
}

+(CGFloat)heightForCell{
    return 55;
}

- (void)prepareForInterfaceBuilder
{
    self.preSelected = NO;
    self.selectedImageView.image = [UIImage imageNamed:@"btn_public_checker_normal"];
}
@end
