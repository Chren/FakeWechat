//
//  LDColorUtil.m
//  ORead
//
//  Created by chhren on 4/19/14.
//  Copyright (c) 2014 ORead. All rights reserved.
//

#import "ORColorUtil.h"

@implementation UIColor(Custom)

+ (UIColor *)colorFromString:(NSString *)aColorString alpha:(CGFloat)aAlpha
{
    if (aColorString.length == 0) {
        return nil;
    }
    
    if ([aColorString hasPrefix:@"#"]) {
        aColorString = [aColorString substringFromIndex:1];
    }
    
    if (aColorString.length == 6) {
        int len = (int)aColorString.length/3;
        unsigned int a[3];
        for (int i=0; i<3; i++) {
            NSRange range;
            range.location = i*len;
            range.length = len;
            NSString *str = [aColorString substringWithRange:range];
            [[NSScanner scannerWithString:str] scanHexInt:a+i];
            if (len == 1) {
                a[i] *= 17;
            }
        }
        return [self colorWithRed:a[0]/255.0f green:a[1]/255.0f blue:a[2]/255.0f alpha:aAlpha];
    }
    else if (aColorString.length <= 2) {
        unsigned int gray;
        [[NSScanner scannerWithString:aColorString] scanHexInt:&gray];
        if (aColorString.length == 1)
        {
            gray *= 17;
        }
        return [self colorWithWhite:gray/255.0f alpha:aAlpha];
    }
    return nil;
}

+ (UIColor *)colorFromString:(NSString *)aColorString
{
    return [self colorFromString:aColorString alpha:1.0f];
}

+ (NSString *)stringFromColor:(UIColor *)aColor
{
    const CGFloat *rgba = CGColorGetComponents(aColor.CGColor);
    NSString *colorString =[NSString stringWithFormat:@"%02X%02X%02X",(int)(rgba[0]*255),(int)(rgba[1]*255),(int)(rgba[2]*255)];
    return colorString;
}

@end
