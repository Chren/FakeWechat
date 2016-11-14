//
//  ORBaseCollectionViewCell.m
//  ORead
//
//  Created by noname on 15/4/14.
//  Copyright (c) 2015年 ORead. All rights reserved.
//

#import "ORBaseCollectionViewCell.h"

@implementation ORBaseCollectionViewCell

-(void)setChecked:(BOOL)isChecked
{
    _isChecked = isChecked;
}


+(CGSize)sizeForCell
{
    return CGSizeZero;
}

- (void)bindWithData:(id)aData
{
    
}

#pragma mark - Reuse
-(void)prepareForReuse
{
	[super prepareForReuse];
    [self setChecked:NO];
}

@end
