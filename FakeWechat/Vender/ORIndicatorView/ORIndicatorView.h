//
//  ORIndicatorView.h
//  ORead
//
//  Created by noname on 14-7-26.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import "MBProgressHUD.h"

@interface ORIndicatorView : MBProgressHUD
// ---- 不会自动消失的view ----
/**
 *  在window中显示loading框
 *
 *  @return loading框的实例
 */
+ (MBProgressHUD *)showLoading;

/**
 *  在view中显示loading框
 *
 *  @param aView 要显示的view
 *
 *  @return loading框的实例
 */
+ (MBProgressHUD *)showLoadingInView:(UIView *)aView;

/**
 *  在window中显示带文字的loading框
 *
 *  @param aString loading后面文字
 *
 *  @return loading框的实例
 */
+ (ORIndicatorView *)showLoadingString:(NSString *)aString;
/**
 *  在view中显示带文字的loading框
 *
 *  @param aString loading后面文字
 *  @param aView   loading框所在的view
 *
 *  @return loading框的实例
 */
+ (ORIndicatorView *)showLoadingString:(NSString *)aString inView:(UIView *)aView;
/**
 *  更新loading框中的文字
 *
 *  @param aString 新的文字
 */
- (void)updateLoadingString:(NSString *)aString;

/**
 *  显示自定义的view
 *
 *  @param aCustomView 自定义的view
 *  @param aView       自定义框所在的view
 *
 *  @return loading框的实例
 */
+ (ORIndicatorView *)showCustomView:(UIView *)aCustomView inView:(UIView *)aView;

/**
 *  显示会自动消失自定义的view
 *
 *  @param aCustomView 自定义的view
 *  @param aView       自定义框所在的view
 *
 *  @return loading框的实例
 */
+ (ORIndicatorView *)showCustomView:(UIView *)aCustomView inView:(UIView *)aView hideAfterDelay:(CGFloat)aDelay;

// ---- 会自动消失的view ----
/**
 *  显示提示文字（2秒后消失）
 *
 *  @param aString 文字
 *
 *  @return loading框的实例
 */
+ (MBProgressHUD *)showString:(NSString *)aString;

/**
 *  在指定view上显示提示文字
 *
 *  @param aString 要显示的文字
 *  @param aView   要显示的view
 *
 *  @return MBProgressHUD的实例
 */
+ (MBProgressHUD *)showString:(NSString *)aString inView:(UIView *)aView;


// ---- 隐藏view ----
/**
 *  在window中隐藏loading框
 */
- (void)hideLoading;

/**
 *  在view中隐藏loading框
 *
 *  @param aView loading框所在的view
 */
+ (void)hideAllInView:(UIView *)aView;
@end
