//
//  GSBaseViewController.m
//  GlassStore
//
//  Created by noname on 15/1/15.
//  Copyright (c) 2015年 ORead. All rights reserved.
//

#import "ORBaseViewController.h"
#import "AppUtil.h"
#import "ORIndicatorView.h"
#import "ORColorUtil.h"

UINavigationController* rootViewController()
{
    UINavigationController *rootViewControler = (UINavigationController *)[[UIApplication sharedApplication].delegate window].rootViewController;
    return rootViewControler;
}

UIViewController *lastPresentedController()
{
    UIViewController *controller = rootViewController();
    while (controller.presentedViewController)
    {
        controller = controller.presentedViewController;
    }
    return controller;
}

void dismissAllPresentedController()
{
    UINavigationController *root= rootViewController();
    
    while (lastPresentedController() != root) {
        [lastPresentedController() dismissViewControllerAnimated:NO completion:NULL];
    }
}

@interface ORBaseViewController (){
    BOOL _isBaseViewAppearred;
    BOOL _isBaseLoading;
}
@end

@implementation ORBaseViewController

- (void)dealloc
{
    [self unloadModel];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    DDLogDebug(@"dealloc - %@",[self class]);
}

- (void)baseViewControllerInit
{
    DDLogDebug(@"init - %@",[self class]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([AppUtil systemVersion].floatValue < 7.0f)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
        [self setWantsFullScreenLayout:YES];
    }
#pragma GCC diagnostic pop
    [self commonInit];
}

- (void)commonInit
{
    [self loadModel];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        [self baseViewControllerInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self baseViewControllerInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = ORColor(kORBackgroundColor);
    if ([AppUtil systemVersion].floatValue < 7.0f)
    {
        if ([self respondsToSelector:@selector(tableView)])
        {
            [[(id)self tableView] setContentInset:UIEdgeInsetsMake(44.0f, 0.0f, 0.0f, 0.0f)];
        }
    }
    
    if ([AppUtil systemVersion].floatValue < 7.0f)
    {
        [self.navigationController.navigationBar setTranslucent:NO];
        [self.navigationController.navigationBar setTintColor:ORColor(kORColorNavBar)];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }else{
        [self.navigationController.navigationBar setTranslucent:NO];
        [self.navigationController.navigationBar setBarTintColor:ORColor(kORColorNavBar)];
    }
    
    NSDictionary * dict = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:18]};
    
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    if (self.isNavBarHide == NO)
    {
        if (self.navigationController.viewControllers.count > 1)
        {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIViewController *preVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
            NSString *previousTitle = preVC.title;
            [backButton setImage:[UIImage imageNamed:@"barbuttonicon_back"] forState:UIControlStateNormal];
            [backButton setTitle:previousTitle forState:UIControlStateNormal];
            backButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [backButton sizeToFit];
            [backButton addTarget:self action:@selector(onBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        }
        else if (self.needCloseButton)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"取消" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
            [button sizeToFit];
            [button addTarget:self action:@selector(onBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:button];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.isNavBarHide animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isBaseViewAppearred == NO)
    {
        _isBaseViewAppearred = YES;
        
        if (self.showLoadingWhenLoadData)
        {
            [self startRefresh];
        }
    }
    else if (_isBaseLoading)
    {
        [self showLoadingView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - 按钮事件
- (IBAction)onBackButtonPressed:(id)sender
{
    if (self.navigationController)
    {
        if (self.navigationController.viewControllers.count == 1)
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)onOkButtonPressed:(id)sender
{
    NSAssert(0, @"子类必须继承该类");
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//- (UIView *)getFailedView
//{
//    UIView *failedView = LDLoadNib(@"LDGuideLoadingFailed");
//    [LDViewUtil addSingleTapGestureForView:failedView target:self action:@selector(onFailedViewTapped:)];
//
//    return failedView;
//}

- (IBAction)onFailedViewTapped:(id)sender
{
    [self startRefresh];
//    [self.failedView removeFromSuperview];
//    [self setFailedView:nil];
}


#pragma mark - 数据模型

- (void)loadModel
{
    
}

- (void)unloadModel
{
    if (self.model != nil)
    {
        DDLogError(@"子类要重写该类");
        //        NSAssert(0, @"子类需要重写该类");
    }
}

- (void)startRefresh
{
    [self showLoadingView];
}

- (void)stopLoadingWithSuccess:(BOOL)aSuccess
{
    if (self.showLoadingWhenLoadData)
    {
        [self hideLoadindView];
        if (aSuccess== NO)
        {
            //            if (self.failedView == nil)
            //            {
            //                UIView *failedView = [self getFailedView];
            //                [self setFailedView:failedView];
            //            }
            //            [self.failedView setFrame:self.view.bounds];
            //            [self.view addSubview:self.failedView];
        }
    }
}

#pragma mark - loading
- (ORIndicatorView *)showLoadingView
{
    _isBaseLoading = YES;

    if (!self.loadingText) {
        self.loadingText = @"加载中";
    }
    
    ORIndicatorView *indicator = [ORIndicatorView showLoadingString:self.loadingText inView:self.view];
    if (_isNavBarHide == YES)
    {
        [indicator setUserInteractionEnabled:NO];
    }
    return indicator;
}

- (void)hideLoadindView
{
    [ORIndicatorView hideAllInView:self.view];
    _isBaseLoading = NO;
}




@end
