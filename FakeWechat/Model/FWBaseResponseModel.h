//
//  FWBaseResponseModel.h
//  FakeWechat
//
//  Created by Aren on 2016/10/27.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWBaseJSONModel.h"

@interface FWBaseResponseModel : FWBaseJSONModel
@property (assign, nonatomic) NSInteger errorcode;
@property (copy, nonatomic) NSString *errormsg;
@property (strong, nonatomic) NSDictionary *data;
@end
