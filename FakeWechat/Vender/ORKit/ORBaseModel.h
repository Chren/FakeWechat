//
//  ORBaseModel.h
//  ORead
//
//  Created by noname on 15/4/6.
//  Copyright (c) 2015年 ORead. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kKeyPathDataFetchResult @"dataFetchResult"

@interface ORBaseModel : NSObject
@property (nonatomic, strong) id dataFetchResult;
@property (nonatomic, assign) BOOL forceUseCache;

/**
 *  从服务器获取数据
 */
-(void)fetchData;
@end
