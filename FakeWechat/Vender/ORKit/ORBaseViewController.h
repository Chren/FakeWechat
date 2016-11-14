//
//  ORBaseViewController.h
//  GlassStore
//
//  Created by noname on 15/1/15.
//  Copyright (c) 2015年 ORead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORBaseModel.h"

UINavigationController* rootViewController();
UIViewController *lastPresentedController();
void dismissAllPresentedController();

@interface ORBaseViewController : UIViewController

#pragma mark - 子类需要重写的类
- (void)commonInit;
@property (nonatomic, strong) ORBaseModel *model;
#pragma mark - 子类可以访问的通用的类
@property (assign, nonatomic) BOOL isNavBarHide;
@property (assign, nonatomic) BOOL needCloseButton;
@property (assign, nonatomic) BOOL showLoadingWhenLoadData;
@property (nonatomic, strong) NSString *loadingText;
- (void)loadModel;
- (void)unloadModel;

- (IBAction)onBackButtonPressed:(id)sender;
- (IBAction)onOkButtonPressed:(id)sender;

// 刷新数据
- (void)startRefresh;

- (void)stopLoadingWithSuccess:(BOOL)aSuccess;
@end
