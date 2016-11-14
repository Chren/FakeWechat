//
//  FWMarryMeViewController.m
//  FakeWechat
//
//  Created by Aren on 2016/11/12.
//  Copyright © 2016年 Aren. All rights reserved.
//

#import "FWMarryMeViewController.h"
#import<AVFoundation/AVFoundation.h>

@interface FWMarryMeViewController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *diamondImageView;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *disagreeButton;
@property (strong, nonatomic) AVAudioPlayer *bgmPlayer;
@property (strong, nonatomic) AVAudioPlayer *speakPlayer;
@end

@implementation FWMarryMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.diamondImageView.layer.cornerRadius = 6;
    self.diamondImageView.layer.masksToBounds = YES;
    self.agreeButton.layer.cornerRadius = 4;
    self.disagreeButton.layer.cornerRadius = 4;
    NSError *error = nil;
    @try {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"wylbdml" ofType:@"mp3"]];
        self.bgmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.bgmPlayer.volume = 0.06;
        self.bgmPlayer.numberOfLoops = -1;
        [self.bgmPlayer play];
    } @catch (NSException *exception) {
        
    }
    
//    @try {
//// 告白录音
//        NSURL *speakUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Track15" ofType:@"mp3"]];
//        self.speakPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:speakUrl error:&error];
//        self.speakPlayer.numberOfLoops = 1;
//        self.speakPlayer.volume = 1;
//        [self.speakPlayer play];
//    } @catch (NSException *exception) {
//        
//    }
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

#pragma mark - Action
- (IBAction)onAgreeButtonAction:(id)sender {
    [self.view removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(onMarryMeViewControllerDismiss:)]) {
        [self.delegate onMarryMeViewControllerDismiss:self];
    }
}

@end
