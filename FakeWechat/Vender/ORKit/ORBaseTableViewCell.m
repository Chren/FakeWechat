//
//  ORBaseTableViewCell.m
//  ORead
//
//  Created by noname on 15/4/14.
//  Copyright (c) 2015年 ORead. All rights reserved.
//

#import "ORBaseTableViewCell.h"

@implementation ORBaseTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGFloat)heightForCell{
    return 0;
}

-(void)setChecked:(BOOL)isChecked
{
    
}

- (void)bindWithData:(id)aData
{
    
}

-(void)prepareForReuse
{
	[super prepareForReuse];
    [self setChecked:NO];
}
@end
