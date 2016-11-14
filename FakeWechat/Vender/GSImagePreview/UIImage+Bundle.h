//
//  UIImage+Bundle.h
//  GSImagePreview
//
//  Created by Aren on 15/9/17.
//  Copyright (c) 2015年 Aren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Bundle)
+ (UIImage *)imageNamed:(NSString *)name inBundleName:(NSString *)aBundleName;
@end
