//
//  ORHttpUtil.h
//  PatientClient
//
//  Created by Aren on 16/3/11.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORHttpUtil : NSObject
+ (NSDictionary *)paramsFromUrl:(NSURL *)anUrl;
@end
