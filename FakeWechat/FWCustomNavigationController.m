//
//  FWCustomNavigationController.m
//  FakeWechat
//
//  Created by Aren on 2016/10/21.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWCustomNavigationController.h"
#import "AppUtil.h"
#import "ORColorUtil.h"

@interface FWCustomNavigationController ()

@end

@implementation FWCustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    if ([AppUtil systemVersion].floatValue < 7.0f)
    {
        [self.navigationBar setTranslucent:NO];
        [self.navigationBar setTintColor:ORColor(kORColorNavBar)];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    } else {
        [self.navigationBar setTranslucent:NO];
        [self.navigationBar setBarTintColor:ORColor(kORColorNavBar)];
    }
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSDictionary * dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationBar.titleTextAttributes = dict;
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

@end
