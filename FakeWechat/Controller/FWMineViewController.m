//
//  FWMineViewController.m
//  FakeWechat
//
//  Created by Aren on 2016/10/21.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWMineViewController.h"
#import "FWSession.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ORColorUtil.h"

@interface FWMineViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *wechatidLabel;

@end

@implementation FWMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我";
    self.headImageView.layer.cornerRadius = 6;
    self.headImageView.layer.borderWidth = 0.5;
    self.headImageView.layer.borderColor = ORColor(@"b2b2b2").CGColor;
    self.headImageView.layer.masksToBounds = YES;
    [self renderProfile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[FWSession shareInstance] updateUserInfo];
}

- (void)commonInit
{
    [super commonInit];
    [[FWSession shareInstance] addObserver:self forKeyPath:kKeyPathSessionInfo options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc
{
    [[FWSession shareInstance] removeObserver:self forKeyPath:kKeyPathSessionInfo];
}

#pragma mark - UI
- (void)renderProfile
{
    FWLoginUserModel *userInfo = [FWSession shareInstance].sessionInfo;
    self.nameLabel.text = userInfo.name;
    self.wechatidLabel.text = userInfo.wechatid;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.photo] placeholderImage:[UIImage imageNamed:@"DefaultHead"]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 14.0;
    } else {
        return 22.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.isViewLoaded == NO) {
        return;
    }
    if ([keyPath isEqualToString:kKeyPathSessionInfo]) {
        [self renderProfile];
    }
}

@end
