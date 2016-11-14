//
//  FWMarryMeViewController.h
//  FakeWechat
//
//  Created by Aren on 2016/11/12.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "ORBaseViewController.h"
@class FWMarryMeViewController;
@protocol FWMarryMeViewControllerDelegate<NSObject>
@optional
- (void)onMarryMeViewControllerDismiss:(FWMarryMeViewController *)viewController;
@end
@interface FWMarryMeViewController : ORBaseViewController
@property (weak, nonatomic) id<FWMarryMeViewControllerDelegate> delegate;
@end
