//
//  FWAddressBookViewController.m
//  FakeWechat
//
//  Created by Aren on 2016/10/21.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWAddressBookViewController.h"
#import "FWAddressBookListModel.h"
#import "FWAddressSystemCellInfo.h"
#import "FWChatViewController.h"
#import "YDSelectPersonCell.h"
#import "ORColorUtil.h"
#import "FWUserModel.h"
#import <RongIMKit/RongIMKit.h>
#import "YXTargetActionManager.h"

@interface FWAddressBookViewController ()
<UISearchBarDelegate,
UISearchResultsUpdating>
@property (strong, nonatomic) FWAddressBookListModel *addressBookListModel;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultViewController;
@end

@implementation FWAddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"通讯录";
    [self configTableView];
    [self configNavBar];
    [self.addressBookListModel constructContactList];
    [self.tableView reloadData];
}

- (void)commonInit
{
    [super commonInit];
    self.singleSelection = YES;
}

- (void)configNavBar
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"barbuttonicon_addfriends"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onRightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -17 + 11;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, addItem];
//    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)configTableView
{
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.allowsMultipleSelection = !self.singleSelection;
    self.tableView.sectionIndexColor = ORColor(@"555555");

    UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"FWContactSearchResultNavController"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.searchBar.delegate = self;
    //    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar setBackgroundImage:[UIImage new]];
    [self.searchController.searchBar setTranslucent:YES];
    
//    [self.searchController.searchBar setTintColor:ORColor(@"efeff4")];
//    self.searchController.searchBar.backgroundColor = ORColor(@"efeff4");
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.searchController.searchBar.placeholder = @"搜索";
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"YDSelectPersonCell" bundle:nil] forCellReuseIdentifier:@"YDSelectPersonCell"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UITextField *searchField;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
        searchField=[self.searchController.searchBar.subviews objectAtIndex:1];
    else
        searchField=[((UIView *)[self.searchController.searchBar.subviews objectAtIndex:0]).subviews lastObject];
    UIImageView *voiceImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VoiceSearchStartBtn"]];
    voiceImgView.contentMode = UIViewContentModeCenter;
    [voiceImgView setImage:[UIImage imageNamed:@"VoiceSearchStartBtn"]];
    voiceImgView.frame = CGRectMake(20, 0, 22-10, 22);
    searchField.rightView = voiceImgView;
    searchField.rightViewMode = UITextFieldViewModeAlways;
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
- (void)loadModel
{
    [self unloadModel];
    self.addressBookListModel = [[FWAddressBookListModel alloc] init];
    self.addressBookListModel.showSystem = YES;
    [self.addressBookListModel addObserver:self forKeyPath:kKeyPathForAllFriends options:NSKeyValueObservingOptionNew context:nil];
    [self.addressBookListModel addObserver:self forKeyPath:kKeyPathForFilteredFriends options:NSKeyValueObservingOptionNew context:nil];
    [self.addressBookListModel addObserver:self forKeyPath:kKeyPathDataFetchResult options:NSKeyValueObservingOptionNew context:nil];
}

- (void)unloadModel
{
    @try {
        [self.addressBookListModel removeObserver:self forKeyPath:kKeyPathForAllFriends];
        [self.addressBookListModel removeObserver:self forKeyPath:kKeyPathForFilteredFriends];
        [self.addressBookListModel removeObserver:self forKeyPath:kKeyPathDataFetchResult];
        [self setAddressBookListModel:nil];
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableCellWithIdentifier = @"YDSelectPersonCell";
    UITableViewCell *cell = nil;
    
    NSInteger row = indexPath.row;
    
    if (tableView == self.tableView) {
        YDSelectPersonCell *contactCell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier forIndexPath:indexPath];
        
        NSString *key = [self.addressBookListModel.allKeys objectAtIndex:indexPath.section];
        NSArray *arrayForKey = [self.addressBookListModel.allFriends objectForKey:key];
        contactCell.showSelection = !self.singleSelection;
        if ([key isEqualToString:kAddressBookSystemKey]) {
            FWAddressSystemCellInfo *systemInfo = [arrayForKey objectAtIndex:row];
            [contactCell bindWithData:systemInfo];
        } else {
            FWUserModel *userInfo = arrayForKey[row];
            if(userInfo){
                [contactCell bindWithData:userInfo];
            }
        }
        
        cell = contactCell;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return [self.addressBookListModel.allKeys count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [self.addressBookListModel.allKeys objectAtIndex:section];
    NSArray *arr = [self.addressBookListModel.allFriends objectForKey:key];
    return arr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [YDSelectPersonCell heightForCell];
}

//pinyin index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return self.addressBookListModel.allKeys;
    } else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        NSString *key = [self.addressBookListModel.allKeys objectAtIndex:section];
        if (![key isEqualToString:kAddressBookSystemKey]) {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 15)];
            headerView.backgroundColor = ORColor(kORBackgroundColor);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 20, 10)];
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = ORColor(@"8e8e93");
            label.text = key;
            [headerView addSubview:label];
            return headerView;
        } else {
            return nil;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        NSString *key = [self.addressBookListModel.allKeys objectAtIndex:section];
        if (![key isEqualToString:kAddressBookSystemKey]) {
            return 20;
        } else {
            return 0;
        }
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    YDSelectPersonCell *cell = (YDSelectPersonCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (tableView == self.tableView) {
        if ([cell.userInfo isKindOfClass:[FWAddressSystemCellInfo class]]) {

        } else {
            if (self.singleSelection) {
                FWUserModel *userInfo = (FWUserModel *)cell.userInfo;
                NSDictionary *dict = @{@"targetId":@(userInfo.userid).stringValue,
                                       @"type":@(ConversationType_PRIVATE)};
                [[YXTargetActionManager sharedInstance] performTarget:@"chat" action:@"privateChatAction" params:dict];
//                FWChatViewController *chatVC = [FWChatViewController chatViewControllerWithUid:@(userInfo.userid).stringValue conversationType:ConversationType_PRIVATE];
//                chatVC.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:chatVC animated:YES];
            }
        }
    }
}

#pragma mark - UISearchResultsUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self loadingYDSearchResultsTableView];
}


- (void)loadingYDSearchResultsTableView
{
//    UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
//    self.vc =  (YDSearchResultsTableViewController *)navController.topViewController;
//    
//    self.vc.tableView.allowsMultipleSelection = !self.singleSelection;//是否可以选择多行，默认为NO
//    self.vc.addressBookSearchListModel =  self.searchListModel;
//    self.vc.addressBookListModel = self.listModel;
//    self.vc.singleSelection =  self.singleSelection;
//    self.vc.disablePreselected = self.disablePreselected;
//    self.vc.cellStyle = YDCellStyleChat;
//    self.vc.delegate = self;
//    [self.vc.tableView reloadData];
}

//#pragma mark -- YDSearchResultsTableViewControllerDelegate
//- (void)addressBookView:(YDSearchResultsTableViewController *)aAddressBookView seletedUsers:(NSArray *)seletedUsers
//{
//    if (self.clickDoneCompletion) {
//        self.clickDoneCompletion(self, seletedUsers, nil);
//    }
//}
//
//- (void)addressBookView:(YDSearchResultsTableViewController *)aAddressBookView isSelected:(YDFriendInfo *)userInfo isChooseAndSelected:(BOOL)isChooseAndSelected;
//{
//    if (isChooseAndSelected) {
//        [self.listModel selectUserWithUserInfo:userInfo];
//    } else {
//        [self.listModel deselectUserWithUserInfo:userInfo];
//    }
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //回调或者说是通知主线程刷新，
//        [aAddressBookView.navigationController dismissViewControllerAnimated:YES completion:NULL];
//        [self.tableView reloadData];
//    });
//}

#pragma mark - Actions
- (IBAction)onRightButtonPressed:(id)sender
{

}
//-(void)onDoneAction:(id) sender
//{
//    if (self.listModel.selectedFriends.count == 0) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请选择联系人!" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        return;
//    }
//    
//    NSMutableArray *newSeletedUsers = [NSMutableArray new];
//    
//    // get seleted users
//    NSMutableArray *seletedUsers = [NSMutableArray new];
//    
//    for (NSString *uid in self.listModel.preselectedFriends) {
//        YDFriendInfo *friendInfo = [self.listModel userinfoWithUid:uid.longLongValue];
//        if (friendInfo) {
//            RCUserInfo *rcUserInfo = [[RCUserInfo alloc] initWithFriendUserInfo:friendInfo];
//            [seletedUsers addObject:rcUserInfo];
//        }
//    }
//    
//    for (YDFriendInfo *baseUserInfo in self.listModel.selectedFriends) {
//        RCUserInfo *rcUserInfo = [[RCUserInfo alloc] initWithFriendUserInfo:baseUserInfo];
//        [seletedUsers addObject:rcUserInfo];
//        [newSeletedUsers addObject:rcUserInfo];
//    }
//    
//    if (self.clickDoneCompletion) {
//        self.clickDoneCompletion(self, seletedUsers, newSeletedUsers);
//    }
//}

#pragma mark - searchResultDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    self.searchListModel.searchKey = searchBar.text;
//    [self.searchListModel fetchList];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.isViewLoaded == NO) {
        return;
    }
    if ([keyPath isEqualToString:kKeyPathForAllFriends]) {
        [self.tableView reloadData];
    } else if ([keyPath isEqualToString:kKeyPathForFilteredFriends]) {
        [self.searchResultViewController.tableView reloadData];
    }
}

@end
