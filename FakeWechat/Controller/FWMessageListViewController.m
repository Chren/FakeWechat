//
//  FWMessageListViewController.m
//  FakeWechat
//
//  Created by Aren on 2016/10/21.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWMessageListViewController.h"
#import "FakeWechat-Swift.h"
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import <MGSwipeTableCell/MGSwipeButton.h>
#import "M13BadgeView.h"
#import "FWChatListModel.h"
#import "ORColorUtil.h"
#import <RongIMKit/RongIMKit.h>
#import "FWChatListCell.h"
#import "FWMoreMenuCell.h"
#import "FWChatViewController.h"
#import "FWBaseResponseModel.h"
#import "ViewUtil.h"
#import "FWErrorDef.h"
#import "FWUnreadManager.h"
#import "ORImageUtil.h"

@interface FWMessageListViewController ()
<MGSwipeTableCellDelegate,
UISearchBarDelegate,
UISearchResultsUpdating,
UISearchControllerDelegate>
@property (strong, nonatomic) FWChatListModel *listModel;
@property (strong, nonatomic) M13BadgeView *contactBadgeView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) Popover *menuPopover;
@property (strong, nonatomic) NSArray *menuDataSource;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultViewController;
@end

@implementation FWMessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateTitle];
    [self configTableView];
    [self configNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[FWUnreadManager shareInstance] checkUnreadCount];
    [self.listModel fetchList];
}

- (void)updateTitle
{
    if ([FWUnreadManager shareInstance].unreadMessageCount > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [NSString stringWithFormat:@"微信(%ld)", [FWUnreadManager shareInstance].unreadMessageCount];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = @"微信";
        });
    }
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

- (void)configNavBar
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"barbuttonicon_add"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onRightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -17 + 11;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, addItem];
}

- (void)configTableView
{
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;

    UIEdgeInsets separatorInset = self.tableView.separatorInset;
    separatorInset.right = 0;
    self.tableView.separatorInset = separatorInset;
    UINavigationController *searchResultsNavController = [[self storyboard] instantiateViewControllerWithIdentifier:@"FWHomeSearchResultNavController"];
    UIViewController *resultVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"FWHomeSearchResultViewController"];
    resultVC.hidesBottomBarWhenPushed = YES;
    self.searchResultViewController = [[searchResultsNavController viewControllers] firstObject];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:resultVC];
    self.searchController.searchBar.delegate = self;
    
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar setBackgroundImage:[UIImage imageFromColor:ORColor(kORBackgroundColor)]];
//    [self.searchController.searchBar setTranslucent:YES];
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.searchController.searchBar.placeholder = @"搜索";
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.searchController.searchBar.frame.size.height)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChatListBackgroundLogo"]];
    imgView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 50)/2, -70, 50, 50);
    headerView.clipsToBounds = NO;
    [headerView addSubview:imgView];
    [headerView addSubview:self.searchController.searchBar];
    self.tableView.tableHeaderView = headerView;
    self.definesPresentationContext = YES;
    
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:ORColor(@"1fbd22")];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FWChatListCell" bundle:nil] forCellReuseIdentifier:@"FWChatListCell"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions
- (IBAction)onRightButtonPressed:(id)sender
{
    [self showMenu:sender];
}

- (NSArray *)createRightButtonsForModel:(RCConversationModel *)aModel
{
    NSMutableArray * result = [NSMutableArray array];
    NSArray* titles = nil;
    if (aModel.isTop) {
        titles = @[NSLocalizedString(@"删除", nil), NSLocalizedString(@"标为未读", nil)];
    } else {
        titles = @[NSLocalizedString(@"删除", nil), NSLocalizedString(@"标为已读", nil)];
    }
    NSArray *colors = @[ORColor(@"df0403"), ORColor(@"a0a0a0")];
    for (int i = 0; i < colors.count; ++i)
    {
        MGSwipeButton *button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            NSLog(@"Convenience callback received (right).");
            BOOL autoHide = i != 0;
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        button.buttonWidth = 80;
        [result addObject:button];
    }
    return result;
}

- (Popover *)menuPopover
{
    if (!_menuPopover) {
        Popover *popOver = [[Popover alloc] initWithShowHandler:^{
            
        } dismissHandler:^{
            
        }];
        _menuPopover = popOver;
        popOver.popoverColor = ORColor(@"49494b");
    }
    return _menuPopover;
}

#pragma mark - Model
- (void)commonInit
{
    [super commonInit];
//    [[FWUnreadManager shareInstance] addObserver:self forKeyPath:kKeyPathTotalUnreadCount options:NSKeyValueObservingOptionNew context:nil];
    self.menuDataSource = @[@{@"title":@"发起群聊", @"icon":@"contacts_add_newmessage"},
                            @{@"title":@"添加朋友", @"icon":@"barbuttonicon_addfriends"},
                            @{@"title":@"扫一扫", @"icon":@"contacts_add_scan"},
                            @{@"title":@"收付款", @"icon":@"receipt_payment_icon"}];
}

- (void)loadModel
{
    [self unloadModel];
    self.listModel = [[FWChatListModel alloc] init];
    [self.listModel addObserver:self forKeyPath:kKeyPathDataSource options:NSKeyValueObservingOptionNew context:nil];
    [self.listModel addObserver:self forKeyPath:kKeyPathDataFetchResult options:NSKeyValueObservingOptionNew context:nil];
    [[FWUnreadManager shareInstance] addObserver:self forKeyPath:kKeyPathTotalUnreadCount options:NSKeyValueObservingOptionNew context:nil];
}

- (void)unloadModel
{
    @try {
        [self.listModel removeObserver:self forKeyPath:kKeyPathDataSource];
        [self.listModel removeObserver:self forKeyPath:kKeyPathDataFetchResult];
        [self setListModel:nil];
        [[FWUnreadManager shareInstance] removeObserver:self forKeyPath:kKeyPathTotalUnreadCount];
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return 1;
    } else if (tableView == self.menuTableView) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return self.listModel.count;
    } else if (tableView == self.menuTableView) {
        return self.menuDataSource.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    static NSString *cellIdentifier = @"FWChatListCell";
    static NSString *menuCellIdentifier = @"FWMoreMenuCell";
    UITableViewCell *cell = nil;
    if (tableView == self.tableView) {
        RCConversationModel *model = [self.listModel objectAtIndex:row];
        FWChatListCell *chatCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [chatCell bindWithModel:model];
        chatCell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
        chatCell.delegate = self;
        cell = chatCell;
    } else if (tableView == self.menuTableView) {
        FWMoreMenuCell *menuCell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
        UIView *view_bg = [[UIView alloc] initWithFrame:cell.frame];
        view_bg.backgroundColor = [UIColor colorWithRed:67/255 green:67/255 blue:69/255 alpha:1];
        menuCell.selectedBackgroundView = view_bg;
        NSDictionary *dict = [self.menuDataSource objectAtIndex:row];
        if (row == self.menuDataSource.count - 1) {
            menuCell.bottomLine.hidden = YES;
        } else {
            menuCell.bottomLine.hidden = NO;
        }
        [menuCell bindWithData:dict];
        cell = menuCell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return [FWChatListCell heightForCell];
    } else if (tableView == self.menuTableView) {
        return [FWMoreMenuCell heightForCell];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, 0)];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, 0)];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (tableView == self.tableView) {
        RCConversationModel *model = [self.listModel objectAtIndex:row];
        if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
            FWChatViewController *chatVC = [FWChatViewController chatViewControllerWithUid:model.targetId conversationType:model.conversationType];
            chatVC.hidesBottomBarWhenPushed = YES;
            chatVC.conversation = model;
            [self.navigationController pushViewController:chatVC animated:YES];
        }
    } else if (tableView == self.menuTableView) {
        [self.menuPopover dismiss];
        if (row == 0) {
            [self pushAddFriend:nil];
        } else if (row == 1) {
            [self pushGroupChat:nil];
        } else if (row == 2) {
            [self pushPrivateChat:nil];
        } else if (row == 3) {
            [self pushNewFriend:nil];
        }
    }
}

#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    RCConversationModel *model = [self.listModel objectAtIndex:indexPath.row];
    return YES;
}

- (BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (direction == MGSwipeDirectionRightToLeft) {
        if (index == 0) {
            NSInteger row = indexPath.row;
            [self.listModel removeConversationAtIndex:row];
        } else if (index == 1) {
            RCConversationModel *model = [self.listModel objectAtIndex:indexPath.row];
            [self.listModel setConversationToTop:indexPath.row isTop:!model.isTop];
        }
    }
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (direction == MGSwipeDirectionRightToLeft) {
        RCConversationModel *model = [self.listModel objectAtIndex:indexPath.row];
        return [self createRightButtonsForModel:model];
    }
    return nil;
}

#pragma mark - SerachControllerDelegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self.searchResultViewController.tableView reloadData];
}

- (void)willPresentSearchController:(UISearchController *)searchController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        searchController.searchResultsController.view.hidden = NO;
    });
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    searchController.searchResultsController.view.hidden = NO;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.isViewLoaded == NO)
    {
        return;
    }
    
    if ([keyPath isEqualToString:kKeyPathDataSource])
    {
        NSIndexSet          *set = change[NSKeyValueChangeIndexesKey];
        NSKeyValueChange    valueChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        switch (valueChange) {
            case NSKeyValueChangeInsertion:
            {
                NSMutableArray *indexes = [NSMutableArray array];
                [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [indexes addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                }];
                [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
            }
                break;
                
            case NSKeyValueChangeRemoval:
            {
                NSMutableArray *indexes = [NSMutableArray array];
                [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [indexes addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                    
                }];
                [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
            }
                break;
                
            case NSKeyValueChangeReplacement:
            {
                NSMutableArray *indexes = [NSMutableArray array];
                
                [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [indexes addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                    
                }];
                
                [self.tableView reloadData];
            }
                break;
                
            case NSKeyValueChangeSetting:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
                break;
            default:
                break;
        }
    } else if ([keyPath isEqualToString:kKeyPathDataFetchResult]) {
        [self stopLoadingWithSuccess:YES];
        
        FWBaseResponseModel *response = change[NSKeyValueChangeNewKey];
        if (response.errorcode == FWErrorCMSuccess) {
            
        } else {
//            [ORIndicatorView showString:@"操作失败!"];
        }
    } else if ([keyPath isEqualToString:kKeyPathTotalUnreadCount]) {
        [self updateTitle];
    }
}

#pragma mark - Actions
- (IBAction)showMenu:(UIButton *)sender {
    UIWindow *window = [ViewUtil keyWindow];
    CGPoint targetPoint = [window convertPoint:sender.center fromView:sender.superview];
    targetPoint.y += sender.frame.size.height/2 + 10;
    
    CGRect rect = self.menuTableView.frame;
    rect.size.height = [FWMoreMenuCell heightForCell]*self.menuDataSource.count;
    rect.size.width = rect.size.width;
    self.menuTableView.frame = rect;
    self.menuPopover.cornerRadius = 2;
    self.menuPopover.sideEdge = 10;
    self.menuPopover.animationIn = 0;
    self.menuPopover.blackOverlayColor = [UIColor clearColor];
    [self.menuPopover show:self.menuTableView point:targetPoint];
    //    self.menuTableView.backgroundColor = ORColor(@"000000");
    [self.menuTableView reloadData];
}

/**
 *  发起群聊聊天
 *
 *  @param sender sender description
 */
- (void) pushGroupChat:(id)sender
{

}

/**
 *  发起私聊
 *
 *  @param sender sender description
 */
- (void)pushPrivateChat:(id)sender
{

}

- (void)pushAddFriend:(id)sender
{
//    YDSearchFriendViewController *searchFriendViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"YDSearchFriendViewController"];
//    searchFriendViewController.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:searchFriendViewController animated:YES];
}

- (void)pushNewFriend:(id)sender
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserCenter" bundle:nil];
//    YDFriendsViewController *friendsView = [storyboard instantiateViewControllerWithIdentifier:@"YDFriendsViewController"];
//    friendsView.title = @"新的朋友";
//    friendsView.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:friendsView animated:YES];
}

- (void)onSearchButtonAction:(id)sender
{
    [self pushAddFriend:nil];
}
@end
