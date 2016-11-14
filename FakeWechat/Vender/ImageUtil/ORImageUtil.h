//
//  ORImageUtil.h
//  ORead
//
//  Created by chhren on 4/19/14.
//  Copyright (c) 2014 ORead. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(Custom)

/**
 *  UIColor -》 UIImage
 *
 *  @param aColor 图片颜色
 *
 *  @return UIImage
 */
+ (UIImage *)imageFromColor:(UIColor *)aColor;

/**
 *  UIView -》 UIImage ，指定scale
 *
 *  @param aView  需要截屏的view
 *  @param aScale 生成的image的scale
 *
 *  @return UIImage
 */
+ (UIImage *)imageFromView:(UIView *)aView scale:(CGFloat)aScale;

/**
 *  UIView -》UIImage
 *
 *  @param aView 需要截屏的view
 *
 *  @return UIImage
 */
+ (UIImage *)imageFromView:(UIView *)aView;

/**
 *  UIView -》 UIImage ，指定区域
 *
 *  @param theView 需要截屏的view
 *  @param aRect   截屏的范围
 *
 *  @return UIImage
 */
+ (UIImage *)imageFromView:(UIView *)theView inRect:(CGRect)aRect;


/**
 *  修正图片的方向
 *
 *  @param aImage 原图
 *
 *  @return 修改后的图片
 */
+ (UIImage *)imageOfFixedOrientation:(UIImage *)aImage;

/**
 *  缩放图片，按比例Fill
 *
 *  @param aSize   缩放的尺寸
 *  @param aOpaque 返回的图片是否不透明
 *  @param aScale  尺寸
 *
 *  @return UIImage
 */
- (UIImage *)scaledToSize:(CGSize)aSize opaque:(BOOL)aOpaque contentMode:(UIViewContentMode)aContentMode scale:(CGFloat)aScale;

/**
 *  缩放图片，按比例Fill
 *
 *  @param aSize  缩放的尺寸
 *
 *  @return UIImage
 */
- (UIImage *)scaledToSize:(CGSize)aSize;

/**
 *  缩放上传图片，按比例Fit，scale 1.0
 *
 *  @param aSize  缩放的尺寸
 *
 *  @return UIImage
 */
- (UIImage *)scaledToUploadSize:(CGSize)aSize;

/**
 *  灰度化图片
 *
 *
 *  @return UIImage
 */
- (UIImage*) grayscaledImage;

+ (UIImage *)imageNamed:(NSString *)name inBundleName:(NSString *)aBundleName;
@end

@interface LDImageUtil : NSObject

@end
