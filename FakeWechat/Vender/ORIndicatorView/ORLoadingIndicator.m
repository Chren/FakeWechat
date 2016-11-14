//
//  ORLoadingIndicator.m
//  ORead
//
//  Created by noname on 14-7-26.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import "ORLoadingIndicator.h"
#import "Observer.h"

@interface ORLoadingIndicator() {
    BOOL _animated;
}
@property (nonatomic, strong) CABasicAnimation *rotateAnimation;
@end


@implementation ORLoadingIndicator

+ (ORLoadingIndicator *)indicator
{
    return [[[self class] alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
}

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onForeground) name:kORObserverEnterForeground object:nil];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setHidden:YES];
    
    if (self.image == nil) {
        [self setImage:[UIImage imageNamed:@"loading_24"]];
    }
    
    [self setContentMode:UIViewContentModeCenter];
    
    [self setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.repeatCount = HUGE_VALF;
    animation.duration = 0.7f;
    [self setRotateAnimation:animation];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)startAnimating
{
    _animated = YES;
    [self setHidden:NO];
    
    [self.layer removeAllAnimations];
    [self.layer addAnimation:self.rotateAnimation forKey:@"rotate360"];
}

- (void)stopAnimating
{
    _animated = NO;
    [self setHidden:YES];
    [self.layer removeAllAnimations];
}

- (void)onForeground
{
    if (_animated)
    {
        [self startAnimating];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
