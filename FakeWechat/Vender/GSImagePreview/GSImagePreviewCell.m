//
//  GSImagePreviewCell.m
//  GSImagePreview
//
//  Created by Aren on 15/9/16.
//  Copyright (c) 2015年 Aren. All rights reserved.
//

#import "GSImagePreviewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Bundle.h"

static const CGFloat kImagePreviewScaleStep = 3.0f;

@interface GSImagePreviewCell()
<UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@end

@implementation GSImagePreviewCell

#pragma mark - Init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    if (self.scrollView == nil)
    {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        [scrollView setDelegate:self];
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView);
        [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_scrollView]-0-|" options:0   metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_scrollView]-0-|" options:0   metrics:nil views:views]];
    }
    
    if (self.imageView == nil)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [self.scrollView addSubview:imageView];
        self.imageView = imageView;
    }
    
    if (self.indicatorView == nil) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.indicatorView = indicatorView;
        self.indicatorView.hidesWhenStopped = YES;
        [self addSubview:self.indicatorView];
        [self.indicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_indicatorView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_indicatorView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];
    }
    
    self.scrollView.delegate = self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (void)bindWithImageObject:(id)anImageObject
{
    if ([anImageObject isKindOfClass:[UIImage class]]) {
        [self bindWithImage:anImageObject];
    } else if ([anImageObject isKindOfClass:[NSString class]]) {
        NSString *strObject = (NSString *)anImageObject;
        if ([strObject hasPrefix:@"http"]) {
            [self bindWithWebImageUrl:strObject];
        } else {
            [self bindWithImagePath:strObject];
        }
    }
}

- (void)bindWithWebImageUrl:(NSString *)anUrl
{
    __weak typeof(self) weakSelf = self;
    [self.indicatorView startAnimating];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:anUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (error) {
            [weakSelf bindWithImage:[UIImage imageNamed:@"gs_img_default" inBundleName:@"GSImagePreview.bundle"]];
            [weakSelf.imageView setContentMode:UIViewContentModeCenter];
        } else {
            [weakSelf bindWithImage:image];
        }
        [weakSelf.indicatorView stopAnimating];
        
        if ([weakSelf.delegate respondsToSelector:@selector(previewCell:onWebImageLoadFinished:error:)]) {
            [weakSelf.delegate previewCell:weakSelf onWebImageLoadFinished:image error:error];
        }
    }];
}

- (void)bindWithImagePath:(NSString *)aPath
{
    __weak typeof(self) weakSelf = self;
    [self.indicatorView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:aPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf bindWithImage:image];
            [weakSelf.indicatorView stopAnimating];
            if ([weakSelf.delegate respondsToSelector:@selector(previewCell:onWebImageLoadFinished:error:)]) {
                [weakSelf.delegate previewCell:weakSelf onWebImageLoadFinished:image error:nil];
            }
        });
    });
}

- (void)bindWithImage:(UIImage *)aImage
{
    [self.imageView setImage:aImage];
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView setDecelerationRate:0.3f];
    
    [self.scrollView setMaximumZoomScale:kImagePreviewScaleStep];
    
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat height = self.scrollView.bounds.size.height;
    CGFloat contentWidth = width;
    CGFloat contentHeight = height;
    
    CGFloat imageHeight =  MAX(1.0, self.imageView.image.size.height);
    CGFloat imageWidth =  MAX(1.0, self.imageView.image.size.width);
    
    contentHeight = width * imageHeight / imageWidth;
//    CGFloat minScale = contentHeight/height;

    [self.scrollView setMinimumZoomScale:1];
    
    [self.scrollView setContentSize:CGSizeMake(fmaxf(width, contentWidth), fmaxf(height, contentHeight))];
    [self.imageView setFrame:CGRectMake(0, -(contentHeight - height)/2, contentWidth, contentHeight)];
    [self.imageView setCenter:CGPointMake(self.scrollView.contentSize.width/2.0, self.scrollView.contentSize.height/2.0)];
}

#pragma mark - UIScrollviewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [scrollView setContentSize:CGSizeMake(fmaxf(scrollView.bounds.size.width, scrollView.contentSize.width), fmaxf(scrollView.bounds.size.height, scrollView.contentSize.height))];
    [self.imageView setCenter:CGPointMake(scrollView.contentSize.width/2,scrollView.contentSize.height/2)];
}

#pragma mark - Scale
- (void)scaleAtPoint:(CGPoint)aPoint
{
    @try {
        if (CGRectContainsPoint(self.imageView.bounds, aPoint)) {
            CGRect zoomRect;
            
            if(self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
                zoomRect.size.height = self.imageView.frame.size.height / self.scrollView.maximumZoomScale;
                zoomRect.size.width  = self.imageView.frame.size.width  / self.scrollView.maximumZoomScale;
            }
            else {
                zoomRect.size.height = self.imageView.frame.size.height * self.scrollView.zoomScale;
                zoomRect.size.width  = self.imageView.frame.size.width  * self.scrollView.zoomScale;
            }
            
            zoomRect.origin.x = aPoint.x - (zoomRect.size.width  / 2.0);
            zoomRect.origin.y = aPoint.y - (zoomRect.size.height / 2.0);
            
            [self.scrollView zoomToRect:zoomRect animated:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"zoom error˜˜˜˜˜˜");
    }
    @finally {
        
    }
}

#pragma mark - Gesture Handler
- (void)handleDoubleTap:(UITapGestureRecognizer *)aRecognizer
{
    CGPoint point = [aRecognizer locationInView:self.imageView];
    [self scaleAtPoint:point];
}

#pragma mark - Reuse
- (void)prepareForReuse
{
    [self.indicatorView stopAnimating];
    [self.imageView setImage:nil];
    self.scrollView.zoomScale = 1.0f;
}
@end
