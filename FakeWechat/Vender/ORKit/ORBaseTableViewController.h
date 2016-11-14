//
//  ORBaseTableViewController.h
//  ORead
//
//  Created by noname on 14-8-2.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORBaseListModel.h"

@interface ORBaseTableViewController : UITableViewController
<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) ORBaseListModel *listModel;
#pragma mark - subclass should override it
/**
 *  init
 */
- (void)commonInit;

/**
 *  load data model
 */
- (void)loadModel;

/**
 *  unload model
 */
- (void)unloadModel;

/**
 *  load list
 */
- (void)startLoadList;

/**
 *  called when pull refresh
 */
- (void)startRefresh;

/**
 *  called when pull down to bottom
 */
- (void)startLoadMore;

#pragma mark - Refresh
@property (nonatomic, assign) BOOL needPullRefesh;
@property (nonatomic, assign) BOOL needLoadMore;
@property (assign, nonatomic) BOOL isNavBarHide;
@property (assign, nonatomic) BOOL needCloseButtonWhenPresent;
@property (assign, nonatomic) BOOL showLoadingWhenLoadList;

- (void)stopLoadingWithSuccess:(BOOL)aSuccess;
@end
