//
//  FWRootNavigationController.m
//  FakeWechat
//
//  Created by Aren on 2016/10/21.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWRootNavigationController.h"
#import "FWRootTabBarController.h"
#import "FWSession.h"

@interface FWRootNavigationController ()

@end

@implementation FWRootNavigationController
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBarHidden = YES;
    [self updateViewControllers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commonInit
{
    // 登入、登出的KVO监听
    [[FWSession shareInstance] addObserver:self forKeyPath:kKeyPathLoginState options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc
{
    [[FWSession shareInstance] removeObserver:self forKeyPath:kKeyPathLoginState];
}

- (void)updateViewControllers
{
    if ([FWSession shareInstance].isLogin)
    {
        UIStoryboard *tabbarStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *tabbarController = [tabbarStoryboard instantiateViewControllerWithIdentifier:@"FWRootTabBarController"];
        [self setViewControllers:@[tabbarController]];
    } else {
        UIStoryboard *accountStoryboard = [UIStoryboard storyboardWithName:@"Account" bundle:nil];
        UIViewController *loginVC = [accountStoryboard instantiateViewControllerWithIdentifier:@"FWLoginViewController"];
        [self setViewControllers:@[loginVC]];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kKeyPathLoginState])
    {
        id loginInfo = [change objectForKey:NSKeyValueChangeNewKey];
        // 登陆成功的通知
        if ([loginInfo boolValue] == YES)
        {
            if (![self.topViewController isKindOfClass:[FWRootTabBarController class]])
            {
                UIStoryboard *tabbarStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *tabbarController = [tabbarStoryboard instantiateViewControllerWithIdentifier:@"FWRootTabBarController"];
                [self setViewControllers:@[tabbarController] animated:NO];
            }
        }
        // 注销成功的通知
        else
        {
            UIStoryboard *accountStoryboard = [UIStoryboard storyboardWithName:@"Account" bundle:nil];
            UIViewController *loginVC = [accountStoryboard instantiateViewControllerWithIdentifier:@"FWLoginViewController"];
            [self setViewControllers:@[loginVC] animated:NO];
        }
    }
}
@end
