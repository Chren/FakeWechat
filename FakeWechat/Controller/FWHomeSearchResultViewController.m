//
//  FWHomeSearchResultViewController.m
//  FakeWechat
//
//  Created by Aren on 2016/11/6.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWHomeSearchResultViewController.h"
#import "ORColorUtil.h"

@interface FWHomeSearchResultViewController ()
@property (weak, nonatomic) IBOutlet UIButton *circleButton;
@property (weak, nonatomic) IBOutlet UIButton *articleButton;
@property (weak, nonatomic) IBOutlet UIButton *publicButton;

@end

@implementation FWHomeSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.backgroundColor = ORColor(@"f5f5f6");
    self.circleButton.layer.cornerRadius = 30;
    self.circleButton.layer.masksToBounds = YES;
    self.articleButton.layer.cornerRadius = 30;
    self.articleButton.layer.masksToBounds = YES;
    self.publicButton.layer.cornerRadius = 30;
    self.publicButton.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapHandle:)];
    [self.tableView addGestureRecognizer:tapRecognizer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTapHandle:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
