//
//  FWChatViewController.m
//  FakeWechat
//
//  Created by Aren on 2016/10/28.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWChatViewController.h"
#import "FWSession.h"
#import "ORColorUtil.h"
#import "YXHttpClient+Message.h"
#import "FWProposalMessage.h"
#import "FWProposalMessageCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "FWUnreadManager.h"
#import "FWMarryMeViewController.h"
#import "TZImagePickerController.h"
#import "GSImageCollectionViewController.h"

static NSString * const kBridegroomUserId = @"1";

static NSString * const kBrideUserId = @"2";

static NSString * const kActressId = @"3";

static NSString * const kMessageRouterUserId = @"4";

static const NSInteger kHongbaoPluginItemTag = 10087;

static const NSInteger kTransferPluginItemTag = 10088;

@interface FWChatViewController ()
<RCPluginBoardViewDelegate,
RCMessageCellDelegate,
FWMarryMeViewControllerDelegate,
TZImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) FWMarryMeViewController *marryMeViewController;
@end

@implementation FWChatViewController

+ (FWChatViewController *)chatViewControllerWithUid:(NSString *)anUid conversationType:(RCConversationType)cType
{
    FWChatViewController *conversationVC = [[FWChatViewController alloc] init];
    RCConversationModel *conversation = [[RCConversationModel alloc] init];
    conversation.conversationType = cType;
    conversation.targetId = anUid;
    
    if (cType == ConversationType_PRIVATE) {
        RCUserInfo *userInfo = [[FWSession shareInstance] getUserInfoWithUserId:anUid];
        conversation.conversationTitle = userInfo.name;
    } else {
        conversation.conversationTitle = @"群聊";
    }
    conversationVC.conversationType = cType;
    conversationVC.targetId = anUid;
    conversationVC.conversation = conversation;
    conversationVC.title = conversation.conversationTitle;
    conversationVC.hidesBottomBarWhenPushed = YES;
    return conversationVC;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (instancetype)init
{
    self = [super init];
    [self commonInit];
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[FWUnreadManager shareInstance] addObserver:self forKeyPath:kKeyPathTotalUnreadCount options:NSKeyValueObservingOptionNew context:nil];
    [[FWUnreadManager shareInstance] checkUnreadCount];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[FWUnreadManager shareInstance] removeObserver:self forKeyPath:kKeyPathTotalUnreadCount];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateTitle];
    NSArray *allItems = [self.chatSessionInputBarControl.pluginBoardView allItems];
    for (UICollectionViewCell *item in allItems) {
        item.contentView.layer.cornerRadius = 8;
        item.contentView.layer.borderWidth = 1;
        item.contentView.layer.borderColor = ORColor(@"dcdcdd").CGColor;
        item.contentView.layer.masksToBounds = YES;
        item.contentView.backgroundColor = ORColor(@"fbfbfc");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configNavBar];
    [self configPluginBoard];
    [self registerClass:[FWProposalMessageCell class] forMessageClass:[FWProposalMessage class]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commonInit
{
//    [[FWUnreadManager shareInstance] addObserver:self forKeyPath:kKeyPathTotalUnreadCount options:NSKeyValueObservingOptionNew context:nil];
}

- (void)configNavBar
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIViewController *preVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    NSString *previousTitle = preVC.navigationItem.title;
    [backButton setImage:[UIImage imageNamed:@"barbuttonicon_back"] forState:UIControlStateNormal];
    [backButton setTitle:previousTitle forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(onBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.backButton = backButton;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"barbuttonicon_InfoSingle"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onRightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -17 + 11;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, addItem];
}

- (void)updateTitle
{
//    UIViewController *preVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    NSString *title = nil;
    if ([FWUnreadManager shareInstance].unreadMessageCount > 0) {
        title = [NSString stringWithFormat:@"微信(%ld)", [FWUnreadManager shareInstance].unreadMessageCount];
    } else {
        title = @"微信";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.backButton setTitle:title forState:UIControlStateNormal];
        [self.backButton sizeToFit];
    });
}

- (void)configPluginBoard
{
    self.chatSessionInputBarControl.pluginBoardView.pluginBoardDelegate = self;
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:0 image:[UIImage imageNamed:@"sharemore_pic"] title:@"照片"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:1 image:[UIImage imageNamed:@"sharemore_video"] title:@"拍摄"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:2 image:[UIImage imageNamed:@"sharemore_sight"] title:@"小视频"];
    
    NSArray *itemArray = @[@{@"img":@"sharemore_videovoip", @"title":@"视频聊天"},
                           @{@"img":@"sharemore_money", @"title":@"红包"},
                           @{@"img":@"sharemore_transfer", @"title":@"转账"},
                           @{@"img":@"sharemore_location", @"title":@"位置"},
                           @{@"img":@"sharemore_myfav", @"title":@"收藏"},
                           @{@"img":@"sharemore_friendcard", @"title":@"个人名片"},
                           @{@"img":@"sharemore_voiceinput", @"title":@"语音输入"},
                           @{@"img":@"sharemore_wallet", @"title":@"卡券"}];
    int tag = 10086;
    for (NSDictionary *dict in itemArray) {
        NSString *imgName = [dict objectForKey:@"img"];
        NSString *title = [dict objectForKey:@"title"];
        [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:imgName] title:title tag:tag];
        tag++;
    }
}

#pragma mark - RCPluginBoardViewDelegate
-(void)pluginBoardView:(RCPluginBoardView*)pluginBoardView clickedItemWithTag:(NSInteger)tag
{
    if ([FWSession shareInstance].sessionInfo.userid == kBridegroomUserId.integerValue) {
        if (tag == kTransferPluginItemTag) {
            [self sendMagic];
        } else if (tag == kHongbaoPluginItemTag) {
            [self sendProposalMessage];
        }
    }
    
    if (tag == 1001) {
        [self openLibraryForPhoto];
        return;
    } else if (tag == 1002) {
        [self openCameraForPhoto];
        return;
    }
}

- (void)sendMagic
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[YXHttpClient sharedClient] sendMagicSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
}

- (void)sendProposalMessage
{
    FWProposalMessage *proposalMsg = [FWProposalMessage messageWithMsg:@"嫁给我吧！"];
    [self sendMessage:proposalMsg pushContent:@"红包"];
}

- (void)alertPropose
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FWMarryMeViewController *marryMeVC = [storyboard instantiateViewControllerWithIdentifier:@"FWMarryMeViewController"];
    marryMeVC.delegate = self;
    self.marryMeViewController = marryMeVC;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:marryMeVC.view];
    marryMeVC.view.frame = window.bounds;
}

#pragma mark - Actions

- (IBAction)onBackButtonPressed:(id)sender
{
//    [[FWUnreadManager shareInstance] removeObserver:self forKeyPath:kKeyPathTotalUnreadCount];
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

- (IBAction)onRightButtonPressed:(id)sender
{
    
}

#pragma mark - Delegate
- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell
                   atIndexPath:(NSIndexPath *)indexPath
{
    cell.tag = indexPath.row;
    if ([self.conversation.targetId isEqualToString:kMessageRouterUserId]) {
        if ([cell isKindOfClass:[RCTextMessageCell class]]) {
            RCTextMessageCell *textCell = (RCTextMessageCell *)cell;
            RCMessageModel *model = textCell.model;
            RCTextMessage *txtMsg = (RCTextMessage *)model.content;
            if ([txtMsg.extra isEqualToString:kActressId]) {
                 textCell.textLabel.textColor = [UIColor whiteColor];
            } else if ([txtMsg.extra isEqualToString:kBrideUserId]) {
                textCell.textLabel.textColor = [UIColor blackColor];
            }
        }
    }
}

- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageCotent
{
    if ([FWSession shareInstance].sessionInfo.userid == kBrideUserId.integerValue && [self.conversation.targetId isEqualToString:kActressId]) {
        [[YXHttpClient sharedClient] sendMessageRouterFrom:kMessageRouterUserId to:kBridegroomUserId message:messageCotent Success:^(NSURLSessionDataTask *task, id responseObject) {
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }
    
    if ([FWSession shareInstance].sessionInfo.userid == kActressId.integerValue && [self.conversation.targetId isEqualToString:kBrideUserId]) {
        [[YXHttpClient sharedClient] sendMessageRouterFrom:kMessageRouterUserId to:kBridegroomUserId message:messageCotent Success:^(NSURLSessionDataTask *task, id responseObject) {
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }

    return messageCotent;
}

- (void)didTapMessageCell:(RCMessageModel *)model
{
    RCMessageContent *messageContent = model.content;
    if ([messageContent isKindOfClass:[FWProposalMessage class]]) {
        [self alertPropose];
    } else if ([messageContent isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *packetMessage = (RCImageMessage *)messageContent;
        GSImageCollectionViewController *imageVC = [GSImageCollectionViewController viewControllerWithDataSource:@[packetMessage.imageUrl]];
        [self.navigationController pushViewController:imageVC animated:YES];
    }
}

- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView
                             cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCMessageModel *model = self.conversationDataRepository[indexPath.row];
    RCMessageContent *messageContent = model.content;
    static NSString *cellIndentifier = @"FWProposalMessageCell";
    if ([messageContent isKindOfClass:[FWProposalMessage class]]) {
        FWProposalMessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIndentifier forIndexPath:indexPath];
        cell.delegate = self;
        [cell setDataModel:model];
        return cell;
    }
    return nil;
}

- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    NSInteger row = indexPath.row;
    RCMessageModel *model = self.conversationDataRepository[row];
    RCMessageContent *message = model.content;
    CGFloat maxWidth = collectionView.frame.size.width;
    if ([message isKindOfClass:[FWProposalMessage class]]) {
        height = [FWProposalMessageCell heightForCellWithModel:model];
    }
    return CGSizeMake(maxWidth, height);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - FWMarryMeViewControllerDelegate
- (void)onMarryMeViewControllerDismiss:(FWMarryMeViewController *)viewController
{
    self.marryMeViewController = nil;
    [self sendMagic];
}

- (void)openLibraryForPhoto
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
//    imagePickerVc.navigationBar.barTintColor = ORColor(kORColorGreen_51D6DB);
//    imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
//    imagePickerVc.oKButtonTitleColorNormal = ORColor(kORColorGreen_51D6DB);
    imagePickerVc.allowPickingVideo = NO;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            for (int i = 0; i < photos.count; i++) {
                RCImageMessage *imgMessage = [RCImageMessage messageWithImage:photos[i]];
                [self sendMediaMessage:imgMessage pushContent:@""];
                //只能一次发一张，发送消息也有频率限制的，每发送一条消息休眠一段时间
                [NSThread sleepForTimeInterval:0.5];
                imgMessage = nil;
            }
        });
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)openCameraForPhoto
{
    //资源类型为照相机
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //判断是否有相机
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = NO;
        //资源类型为照相机
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    }else {
        NSLog(@"该设备无摄像头");
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    RCImageMessage *imgMessage = [RCImageMessage messageWithImage:image];
    [self sendMediaMessage:imgMessage pushContent:@""];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.isViewLoaded == NO)
    {
        return;
    }
    
    if ([keyPath isEqualToString:kKeyPathTotalUnreadCount]) {
        [self updateTitle];
    }
}
@end
