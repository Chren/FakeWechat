//
//  GSImageCollectionViewController.h
//  GSImagePreview
//
//  Created by Aren on 15/9/16.
//  Copyright (c) 2015年 Aren. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef GSImagePreviewLocalizedStrings
#define GSImagePreviewLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"GSImagePreview", nil)
#endif

@interface GSImageCollectionViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (assign, nonatomic) NSInteger defaultPageIndex;
@property (weak, nonatomic) IBOutlet UIView *topToolbarView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

+(instancetype)viewControllerWithDataSource:(NSArray *)aDataSource;

- (void)initTopToolBar;

- (NSInteger)currentPageIndex;

- (void)deleteImageAtIndex:(NSInteger)anIndex;
/**
 *  Called before saving, override it for custom action before save
 */
- (void)willSaveImage;

/**
 *  Called after saving finished, override it for custom action after save
 *
 *  @param anImage     saved image
 *  @param error       error
 *  @param contextInfo contextInfo
 */
- (void)didFinishSaveImage:(UIImage *)anImage withError: (NSError *) error contextInfo: (void *) contextInfo;

@end
