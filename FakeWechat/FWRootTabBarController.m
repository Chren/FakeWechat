//
//  FWRootTabBarController.m
//  FakeWechat
//
//  Created by Aren on 2016/10/21.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWRootTabBarController.h"
#import "ORBaseViewController.h"
#import "ORColorUtil.h"
#import "UITabBar+CutomBadge.h"
#import "FWUnreadManager.h"

@interface FWRootTabBarController ()

@end

@implementation FWRootTabBarController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self coommonInit];
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self coommonInit];
    return self;
}

- (void)coommonInit
{
    [[FWUnreadManager shareInstance] addObserver:self forKeyPath:kKeyPathTotalUnreadCount options:NSKeyValueObservingOptionNew context:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configTabbar];
}

- (void)dealloc
{
    [[FWUnreadManager shareInstance] removeObserver:self forKeyPath:kKeyPathTotalUnreadCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)configTabbar
{
    NSArray *onIcons = @[@"tabbar_mainframeHL",
                         @"tabbar_contactsHL",
                         @"tabbar_discoverHL",
                         @"tabbar_meHL"];
    
    NSArray *offIcons = @[ @"tabbar_mainframe",
                           @"tabbar_contacts",
                           @"tabbar_discover",
                           @"tabbar_me"];
    
    NSArray *items = self.tabBar.items;
    for (NSUInteger i = 0; i < items.count; ++i) {
        UITabBarItem *item = items[i];
        item.image = [[UIImage imageNamed:offIcons[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [[UIImage imageNamed:onIcons[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSFontAttributeName : [UIFont systemFontOfSize:10],NSForegroundColorAttributeName : ORColor(@"7a7e83")}
                                           forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSFontAttributeName : [UIFont systemFontOfSize:10], NSForegroundColorAttributeName : ORColor(@"1fb922")}
                                           forState:UIControlStateHighlighted];
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSFontAttributeName : [UIFont systemFontOfSize:10], NSForegroundColorAttributeName : ORColor(@"1fb922")}
                                           forState:UIControlStateSelected];
    
    [[UITabBar appearance] setTintColor:ORColor(@"1fb922")];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.isViewLoaded == NO)
    {
        return;
    }
    
    if ([keyPath isEqualToString:kKeyPathTotalUnreadCount]) {
        UITabBarItem *tabBarItem = [self.tabBar.items objectAtIndex:0];
        if ([FWUnreadManager shareInstance].unreadMessageCount > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                tabBarItem.badgeValue = [[NSString alloc]initWithFormat:@"%ld", (long)[FWUnreadManager shareInstance].unreadMessageCount];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                tabBarItem.badgeValue = nil;
            });
        }
    }
}


@end

FWRootTabBarController* rootTabBarController()
{
    UINavigationController *nav = rootViewController();
    return [nav.viewControllers objectAtIndex:0];
}
