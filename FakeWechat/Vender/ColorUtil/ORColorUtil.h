//
//  LDColorUtil.h
//  ORead
//
//  Created by chhren on 4/19/14.
//  Copyright (c) 2014 ORead. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ORColor(aColorString) [UIColor colorFromString:aColorString]

/**
 *  color def
 */
#define kORColorRed_F18391 @"F18391"
#define kORColorGreen_00B757 @"00B757"
#define kORColorBlue_50A1E6 @"50A1E6"
#define kORColorBlue_3FB0FF @"3FB0FF"
#define kORColorGray_ABABAB @"ABABAB"
#define kORColorGray_99A1A7 @"99A1A7"

#define kORColorNavBar @"36353a"

#define kORColorGreen_2ABA9B @"2aba9b"
#define kORColorYellow_F5BC23 @"f5bc23"

#define kORSeparatorColor @"dedede"
#define kORBorderColor @"f1f1f1"
#define kORBackgroundColor @"efeff4"
@interface UIColor(Custom)

/**
 *  NSString -》 UIColor
 *
 *  @param aColorString normal:@“#AB12FF” or @“AB12FF” or gray: @"C7"
 *
 *  @return UIColor
 */
+ (UIColor *)colorFromString:(NSString *)aColorString;
/**
 *  NSString -》 UIColor with alpha
 *
 *  @param aColorString normal:@“#AB12FF” or @“AB12FF” or gray: @"C7"
 *  @param aAlpha       alpha 0-1.0
 *
 *  @return UIColor
 */
+ (UIColor *)colorFromString:(NSString *)aColorString alpha:(CGFloat)aAlpha;

/**
 *  UIColor -》 NSString
 *
 *  @param aColor UIColor
 *
 *  @return NSString（format: @“#AB12FF”）
 */
+ (NSString *)stringFromColor:(UIColor *)aColor;

@end
