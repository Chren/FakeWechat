//
//  UITabBar+CutomBadge.m
//  yxtk
//
//  Created by Aren on 2016/11/11.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "UITabBar+CutomBadge.h"

@implementation UITabBar (CutomBadge)
- (void)showBadgeAtIndex:(int)index
{
    [self removeBadgeAtIndex:index];
    UIImageView *badgeImgView = [UIImageView new];
    
    badgeImgView.image = [UIImage imageNamed:@"AlbumNewNotify"];
    badgeImgView.tag = 10086 + index;
    CGRect tabFrame = self.frame;
    NSInteger numbers = self.items.count;
    CGFloat itemWidth = tabFrame.size.width*1.0/numbers;
    CGFloat x = (index+0.5)*itemWidth + 3;
    CGFloat y = 1;
    badgeImgView.frame = CGRectMake(x, y, 20, 20);//圆形大小为10
    [self addSubview:badgeImgView];
}

- (void)hideBadgeAtIndex:(int)index
{
    [self removeBadgeAtIndex:index];
}

- (void)removeBadgeAtIndex:(int)index
{
    for (UIView *subView in self.subviews) {
        if (subView.tag == 10086 + index) {
            [subView removeFromSuperview];
        }
    }
}

@end
