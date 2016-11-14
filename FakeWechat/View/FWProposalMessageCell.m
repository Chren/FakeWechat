//
//  FWProposalMessageCell.m
//  FakeWechat
//
//  Created by Aren on 2016/11/10.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWProposalMessageCell.h"
#import "FWProposalMessage.h"
#import "ORColorUtil.h"
#import <Masonry/Masonry.h>

@implementation FWProposalMessageCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (NSDictionary *)attributeDictionary {
    if (self.messageDirection == MessageDirection_SEND) {
        return @{
                 @(NSTextCheckingTypeLink) : @{NSForegroundColorAttributeName : [UIColor blueColor]},
                 @(NSTextCheckingTypePhoneNumber) : @{NSForegroundColorAttributeName : [UIColor blueColor]}
                 };
    } else {
        return @{
                 @(NSTextCheckingTypeLink) : @{NSForegroundColorAttributeName : [UIColor blueColor]},
                 @(NSTextCheckingTypePhoneNumber) : @{NSForegroundColorAttributeName : [UIColor blueColor]}
                 };
    }
    return nil;
}

- (NSDictionary *)highlightedAttributeDictionary {
    return [self attributeDictionary];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - CustomUI
- (UIImageView *)bubbleBackgroundView
{
    if (!_bubbleBackgroundView) {
        _bubbleBackgroundView = [UIImageView new];
        _bubbleBackgroundView.contentMode = UIViewContentModeScaleToFill;
        _bubbleBackgroundView.clipsToBounds = YES;
        _bubbleBackgroundView.userInteractionEnabled = YES;
    }
    return _bubbleBackgroundView;
}

- (UIImageView *)hongbaoImgView
{
    if (!_hongbaoImgView) {
        _hongbaoImgView = [UIImageView new];
        _hongbaoImgView.image = [UIImage imageNamed:@"message_hongbao"];
    }
    return _hongbaoImgView;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = [UIColor whiteColor];
    }
    return _contentLabel;
}

- (UILabel *)commonLabel
{
    if (!_commonLabel) {
        _commonLabel = [UILabel new];
        _commonLabel.font = [UIFont systemFontOfSize:12];
        _commonLabel.textColor = [UIColor whiteColor];
        _commonLabel.text = @"领取红包";
    }
    return _commonLabel;
}

- (UILabel *)bottomLabel
{
    if (!_bottomLabel) {
        _bottomLabel = [UILabel new];
        _bottomLabel.font = [UIFont systemFontOfSize:10];
        _bottomLabel.text = @"微信红包";
        _bottomLabel.textColor = ORColor(@"9d9d9d");
    }
    return _bottomLabel;
}

- (void)initialize
{
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    [self.messageContentView addSubview:self.hongbaoImgView];
    [self.messageContentView addSubview:self.contentLabel];
    [self.messageContentView addSubview:self.commonLabel];
    [self.messageContentView addSubview:self.bottomLabel];
//    self.messageContentView.backgroundColor = [UIColor greenColor];
    [self.bubbleBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.messageContentView.mas_left).with.offset(0);
        make.right.equalTo(self.messageContentView.mas_right).with.offset(0);
        make.top.equalTo(self.messageContentView.mas_top).with.offset(0);
        make.bottom.equalTo(self.messageContentView.mas_bottom).with.offset(-10);
    }];
    
    [self.hongbaoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.messageContentView.mas_left).with.offset(14);
        make.top.equalTo(self.messageContentView.mas_top).with.offset(10);
        make.height.equalTo(@(40));
        make.width.equalTo(@(34));
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hongbaoImgView.mas_right).with.offset(8);
        make.right.equalTo(self.messageContentView.mas_right).with.offset(-8);
        make.top.equalTo(self.messageContentView.mas_top).with.offset(12);
        make.height.equalTo(@(16));
    }];
    
    [self.commonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentLabel.mas_left).with.offset(0);
        make.right.equalTo(self.contentLabel.mas_right).with.offset(0);
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(5);
        make.height.equalTo(@(14));
    }];

    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hongbaoImgView.mas_left).with.offset(2);
        make.right.equalTo(self.messageContentView.mas_right).with.offset(-2);
        make.bottom.equalTo(self.bubbleBackgroundView.mas_bottom).with.offset(-10);
        make.height.equalTo(@(12));
    }];

    UITapGestureRecognizer *tapPress =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCellTap:)];
    [self.messageContentView addGestureRecognizer:tapPress];
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self setAutoLayout];
}

- (void)setAutoLayout
{
    FWProposalMessage *content = (FWProposalMessage *)self.model.content;
    if(content) {
        self.contentLabel.text = content.message;
    }
    if (MessageDirection_RECEIVE == self.messageDirection)  {
        [self.hongbaoImgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.messageContentView.mas_left).with.offset(14);
            make.top.equalTo(self.messageContentView.mas_top).with.offset(10);
            make.height.equalTo(@(40));
            make.width.equalTo(@(34));
        }];
        
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"c2cReceiverMsgNodeBG"];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.1, image.size.width * 0.8,
                                                                                        image.size.height * 0.75, image.size.width * 0.2)];
    } else {
        [self.hongbaoImgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.messageContentView.mas_left).with.offset(10);
            make.top.equalTo(self.messageContentView.mas_top).with.offset(10);
            make.height.equalTo(@(40));
            make.width.equalTo(@(34));
        }];
        
        self.bubbleBackgroundView.image = [UIImage imageNamed:@"c2cSenderMsgNodeBG"];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.1, image.size.width * 0.8,
                                                                                        image.size.height * 0.75, image.size.width * 0.2)];
    }
}

- (void)onCellTap:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

+ (CGFloat)heightForCellWithModel:(RCMessageModel *)model
{
    CGFloat height = 86+10+10;
    if(model.isDisplayMessageTime) {
        height += 20+10;
    }
    if (model.isDisplayNickname) {
        height += 20;
    }
    return height;
}
@end
