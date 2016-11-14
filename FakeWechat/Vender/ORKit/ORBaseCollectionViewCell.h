//
//  ORBaseCollectionViewCell.h
//  ORead
//
//  Created by noname on 15/4/14.
//  Copyright (c) 2015年 ORead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ORBaseCollectionViewCell : UICollectionViewCell
@property (assign, nonatomic) BOOL isChecked;
/**
 *  return cell size, override it in subclass
 *
 *  @return CGSzie
 */
+(CGSize)sizeForCell;

/**
 *  Replace for setselected
 *
 *  @param isChecked a bool value indicator if it is selected
 */
-(void)setChecked:(BOOL)isChecked;

- (void)bindWithData:(id)aData;
@end
