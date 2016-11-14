//
//  GSImagePreviewCell.h
//  GSImagePreview
//
//  Created by Aren on 15/9/16.
//  Copyright (c) 2015年 Aren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSImagePreviewCell;
@protocol GSImagePreviewCellDelegate<NSObject>
@optional
- (void)previewCell:(GSImagePreviewCell *)aCell onWebImageLoadFinished:(UIImage *)anImage error:(NSError *)anError;
@end

@interface GSImagePreviewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) id<GSImagePreviewCellDelegate> delegate;

/**
 *  Bind data source
 *
 *  @param anImageObject it can be UIImage or url of web image in NSString
 */
- (void)bindWithImageObject:(id)anImageObject;

@end
