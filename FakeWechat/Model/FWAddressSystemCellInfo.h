//
//  FWAddressSystemCellInfo.h
//  FakeWechat
//
//  Created by Aren on 2016/10/28.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWBaseJSONModel.h"
@interface FWAddressSystemCellInfo : FWBaseJSONModel
@property (assign, nonatomic) int cellType;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *imgName;
@end
