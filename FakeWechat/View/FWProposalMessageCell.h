//
//  FWProposalMessageCell.h
//  FakeWechat
//
//  Created by Aren on 2016/11/10.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface FWProposalMessageCell : RCMessageCell
@property (strong, nonatomic) UIImageView *bubbleBackgroundView;
@property (strong, nonatomic) UIImageView *hongbaoImgView;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UILabel *commonLabel;
@property (strong, nonatomic) UILabel *bottomLabel;

+ (CGFloat)heightForCellWithModel:(RCMessageModel *)model;
@end
