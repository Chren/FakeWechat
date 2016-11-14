//
//  FWLoginViewController.m
//  FakeWechat
//
//  Created by Aren on 2016/10/27.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWLoginViewController.h"
#import "ORBaseViewController.h"
#import "FWSession.h"
#import "ORColorUtil.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface FWLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation FWLoginViewController
+ (void)showLoginViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:nil];
    FWLoginViewController *loginView = [storyboard instantiateViewControllerWithIdentifier:@"FWLoginViewController"];
    loginView.hidesBottomBarWhenPushed = YES;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginView];
    
    UIViewController *rootVC = lastPresentedController();
    [rootVC presentViewController:navController animated:YES completion:^{}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Action
- (IBAction)onLoginButtonAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [[FWSession shareInstance] loginWithPhone:self.phoneTextField.text password:self.passwordTextField.text success:^(NSURLSessionDataTask *task, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)aTextField
{
    self.loginButton.enabled = self.phoneTextField.text.length == 11&&self.passwordTextField.text.length > 0;
    self.loginButton.backgroundColor = self.loginButton.enabled?ORColor(@"27aa28"):ORColor(@"a5dda5");
}

@end
