//
//  GSImageCollectionViewController.m
//  GSImagePreview
//
//  Created by Aren on 15/9/16.
//  Copyright (c) 2015年 Aren. All rights reserved.
//

#import "GSImageCollectionViewController.h"
#import "GSImagePreviewCell.h"
#import "UIImage+Bundle.h"
#import <SDWebImage/SDWebImageManager.h>
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface GSImageCollectionViewController ()
<UIGestureRecognizerDelegate,
GSImagePreviewCellDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titlePageLabel;
@property (assign, nonatomic) BOOL defaultNavigationBarHidden;
@property (assign, nonatomic) BOOL defaultStatusBarHidden;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarTopConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (assign, nonatomic) CGFloat lastContentOffsetX;
@end

@implementation GSImageCollectionViewController
+(instancetype)viewControllerWithDataSource:(NSArray *)aDataSource
{
    GSImageCollectionViewController *imageCollectionVC = [[GSImageCollectionViewController alloc] initWithNibName:@"GSImageCollectionViewController" bundle:nil];
    [imageCollectionVC setDataSource:[NSMutableArray arrayWithArray:aDataSource]];
    return imageCollectionVC;
}

#pragma mark - ViewLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fd_prefersNavigationBarHidden = YES;
    // Add tap gesture
    UITapGestureRecognizer *tapGesture  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:tapGesture];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    
    [self initTopToolBar];
    
    // init collectionView
    [self.collectionView registerClass:[GSImagePreviewCell class] forCellWithReuseIdentifier:@"GSImagePreviewCell"];
    [self.pageControl setNumberOfPages:self.dataSource.count];
    self.pageControl.hidden = self.dataSource.count<=1;
    [self updateCurrentPageIndex:self.defaultPageIndex];
    [self.collectionView reloadData];
    if (self.defaultPageIndex > 0) {
        [self tryPreloadPageIndex:self.defaultPageIndex - 1];
    }
    
    if (self.defaultPageIndex < self.dataSource.count - 1) {
        [self tryPreloadPageIndex:self.defaultPageIndex + 1];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.defaultNavigationBarHidden = self.navigationController.navigationBarHidden;
    self.navigationController.navigationBarHidden = YES;
    self.defaultStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.defaultStatusBarHidden withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:self.defaultNavigationBarHidden animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tryPreloadPageIndex:(NSInteger)aPageIndex
{
    if (aPageIndex < self.dataSource.count) {
        id imageObject = [self.dataSource objectAtIndex:aPageIndex];
        if ([imageObject isKindOfClass:[NSString class]]) {
            if (![[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:imageObject]]) {
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageObject] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (error) {
                        NSLog(@"error %@", error.description);
                    }
                }];
            }
        }
    }
}

#pragma mark - Data Source
- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = [NSMutableArray arrayWithArray:dataSource];
    [self.pageControl setNumberOfPages:dataSource.count];
    self.pageControl.hidden = _dataSource.count <= 1;
    [self.collectionView reloadData];
}

#pragma mark - Public
- (NSInteger)currentPageIndex
{
    return [self horizontalPageNumber:self.collectionView];
}

- (void)deleteImageAtIndex:(NSInteger)anIndex
{
    if (anIndex < self.dataSource.count) {
        [self.dataSource removeObjectAtIndex:anIndex];
        [self.collectionView reloadData];
        NSInteger currentPageIndex = [self horizontalPageNumber:self.collectionView];
        [self updateCurrentPageIndex:currentPageIndex];
    }
    
}
#pragma mark - UI Stuff
- (void)initTopToolBar
{
    [self.backButton setImage:[UIImage imageNamed:@"gs_btn_back_arrow" inBundleName:@"GSImagePreview.bundle"] forState:UIControlStateNormal];
    [self.saveButton setImage:[UIImage imageNamed:@"gs_btn_save_normal" inBundleName:@"GSImagePreview.bundle"] forState:UIControlStateNormal];
    [self.saveButton setImage:[UIImage imageNamed:@"gs_btn_save_highlight" inBundleName:@"GSImagePreview.bundle"] forState:UIControlStateHighlighted];
    [self.saveButton setImage:[UIImage imageNamed:@"gs_btn_save_disable" inBundleName:@"GSImagePreview.bundle"] forState:UIControlStateDisabled];
    self.saveButton.enabled = NO;
}

- (void)updateCurrentPageIndex:(NSInteger)aPageIndex
{
    [self.pageControl setNumberOfPages:self.dataSource.count];
    [self.pageControl setCurrentPage:aPageIndex];
    GSImagePreviewCell *cell = (GSImagePreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:aPageIndex inSection:0]];
    self.saveButton.enabled = cell.imageView.image!=nil;
}

- (void)showHudWithString:(NSString *)aString
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(80, 100, 140, 100)];
    CGRect rect = hudView.frame;
    rect.origin.x = (window.frame.size.width - rect.size.width)/2;
    rect.origin.y = (window.frame.size.height - rect.size.height)/2;
    hudView.frame = rect;
    hudView.layer.cornerRadius = 10;
    hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 120, 32)];
    rect = label.frame;
    rect.origin.x = (hudView.frame.size.width - rect.size.width)/2;
    rect.origin.y = (hudView.frame.size.height - rect.size.height)/2;
    label.frame = rect;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [hudView addSubview:label];
    label.text = aString;
    
    [window addSubview:hudView];
    [UIView animateWithDuration:0.4 delay:.8f options:UIViewAnimationOptionCurveEaseOut animations:^{
        hudView.alpha = 0;
    } completion:^(BOOL finished) {
        [hudView removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Private Util
- (NSInteger)horizontalPageNumber:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGSize viewSize = scrollView.bounds.size;
    NSInteger horizontalPage = MAX(0.0, contentOffset.x / viewSize.width);
    return horizontalPage;
}

#pragma mark - UICollectionView Delegate/Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    static NSString *cellIdentifier = @"GSImagePreviewCell";
    GSImagePreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell bindWithImageObject:[self.dataSource objectAtIndex:row]];
    // scroll to preset pageindex if it has been set
    if (self.defaultPageIndex > 0) {
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.defaultPageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        [self updateCurrentPageIndex:self.defaultPageIndex];
        self.defaultPageIndex = 0;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSInteger row = indexPath.row;
    //    CGSize cellSize = CGSizeZero;
    return collectionView.frame.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        NSInteger currentPageIndex = [self horizontalPageNumber:scrollView];
        [self updateCurrentPageIndex:currentPageIndex];
        if (self.lastContentOffsetX < scrollView.contentOffset.x) {
            if (currentPageIndex < self.dataSource.count - 1) {
                [self tryPreloadPageIndex:currentPageIndex + 1];
            }
        } else if (self.lastContentOffsetX > scrollView.contentOffset.x) {
            if (currentPageIndex > 0) {
                [self tryPreloadPageIndex:currentPageIndex - 1];
            }
        }
        self.lastContentOffsetX = scrollView.contentOffset.x;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        self.lastContentOffsetX = scrollView.contentOffset.x;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.collectionView) {
        if (!decelerate) {
            [self updateCurrentPageIndex:[self horizontalPageNumber:scrollView]];
        }
    }
}

#pragma mark - Action
- (IBAction)onBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSaveButtonAction:(id)sender {
    self.saveButton.enabled = NO;
    NSInteger currentIndex = [self horizontalPageNumber:self.collectionView];
    GSImagePreviewCell *cell = (GSImagePreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0]];
    [self willSaveImage];
    UIImageWriteToSavedPhotosAlbum(cell.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark - GestureHandler
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Toolbar
- (void)showToolbar
{
    [self.view setUserInteractionEnabled:NO];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:.25f animations:^{
        self.toolbarTopConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view setUserInteractionEnabled:YES];
    }];
}

- (void)hideToolbar
{
    [self.view setUserInteractionEnabled:NO];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:.25f animations:^{
        self.toolbarTopConstraint.constant = -self.topToolbarView.frame.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view setUserInteractionEnabled:YES];
    }];
}

#pragma mark - Gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (((UITapGestureRecognizer *)otherGestureRecognizer).numberOfTapsRequired == 2) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - GSImagePreviewCellDelegate
- (void)previewCell:(GSImagePreviewCell *)aCell onWebImageLoadFinished:(UIImage *)anImage error:(NSError *)anError
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:aCell];
    if (indexPath.row == [self horizontalPageNumber:self.collectionView]) {
        self.saveButton.enabled = !anError;
    }
}

#pragma mark - Save Image
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    self.saveButton.enabled = YES;
    [self didFinishSaveImage:image withError:error contextInfo:contextInfo];
}

#pragma mark - Override
- (void)willSaveImage
{
    [self.indicatorView startAnimating];
}

- (void)didFinishSaveImage:(UIImage *)anImage withError: (NSError *) error contextInfo: (void *) contextInfo
{
    [self.indicatorView stopAnimating];
    if (error) {
        [self showHudWithString:GSImagePreviewLocalizedStrings(@"Save failed!")];
    } else {
        [self showHudWithString:GSImagePreviewLocalizedStrings(@"Save success!")];
    }
}
@end
