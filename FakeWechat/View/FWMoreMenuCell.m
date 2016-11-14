//
//  YDMoreMenuCell.m
//  yxtk
//
//  Created by Aren on 16/5/16.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "FWMoreMenuCell.h"

@implementation FWMoreMenuCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)bindWithData:(id)aData
{
    NSDictionary *dict = aData;
    self.titleLabel.text = [dict objectForKey:@"title"];
    self.iconImageView.image = [UIImage imageNamed:[dict objectForKey:@"icon"]];
    
    CGRect bottomLineRect = _bottomLine.frame;
    bottomLineRect.size.height = 0.3;
    _bottomLine.frame = bottomLineRect;
}

+ (CGFloat)heightForCell
{
    return 44;
}
@end
