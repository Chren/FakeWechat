//
//  ORBaseTableViewCell.h
//  ORead
//
//  Created by noname on 15/4/14.
//  Copyright (c) 2015年 ORead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ORBaseTableViewCell : UITableViewCell
/**
 *  return cell size, override it in subclass
 *
 *  @return CGFloat
 */
+(CGFloat)heightForCell;

/**
 *  Replace for setselected
 *
 *  @param isChecked a bool value indicator if it is selected
 */
-(void)setChecked:(BOOL)isChecked;

- (void)bindWithData:(id)aData;
@end
