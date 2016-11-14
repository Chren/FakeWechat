//
//  UIImage+Bundle.m
//  GSImagePreview
//
//  Created by Aren on 15/9/17.
//  Copyright (c) 2015年 Aren. All rights reserved.
//

#import "UIImage+Bundle.h"

@implementation UIImage (Bundle)
+ (UIImage *)imageNamed:(NSString *)name inBundleName:(NSString *)aBundleName
{
    UIImage *image = nil;
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:aBundleName];
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];
    image = [[UIImage alloc] initWithContentsOfFile:image_path];
    return image;
}
@end
