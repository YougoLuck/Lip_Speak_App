//
//  UploadVC.m
//  lipspeaker
//
//  Created by Youmaru on 2019/11/18.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import "UploadVC.h"
#import "NetworkMgr.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>

@interface UploadVC ()
@property (assign, nonatomic) CGSize videoSize;
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSString *label;

@property (nonatomic, strong)AVPlayer *player;
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@property (nonatomic, weak) UIView *playerView;


@end

@implementation UploadVC

- (instancetype)initWithVideoSize:(CGSize)size
                        filePath:(NSString *)path
                            label:(NSString *)label {
    if (self = [super init]) {
        self.videoSize = size;
        self.filePath = path;
        self.label = label;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.filePath]];
    UIView *playerView = [[UIView alloc] init];
    playerView.backgroundColor = [UIColor blackColor];
    self.playerView = playerView;
    [self.view addSubview:playerView];
    __weak typeof(self) weakSelf = self;
    [playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(67);
        make.centerX.equalTo(weakSelf.view);
        make.left.equalTo(weakSelf.view).offset(30);
        make.right.equalTo(weakSelf.view).offset(-30);
        make.height.equalTo(playerView.mas_width).multipliedBy(weakSelf.videoSize.height / weakSelf.videoSize.width);
    }];
    AVPlayerLayer *avLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer = avLayer;
    [playerView.layer addSublayer:avLayer];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(runLoopTheMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    UIButton *upload = [[UIButton alloc] init];
    [upload setTitle:@"UPLOAD" forState:UIControlStateNormal];
    [upload setBackgroundColor:[UIColor orangeColor]];
    upload.titleLabel.font = [UIFont systemFontOfSize:25];
    upload.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    upload.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;
    [upload addTarget:self action:@selector(clickUpload:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:upload];
    [upload mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(playerView.mas_bottom).offset(20);
        make.left.equalTo(playerView);
        make.right.equalTo(playerView);
        make.height.equalTo(@(50));
    }];
    
    [self.player play];
}

- (void)clickUpload:(UIButton *)btn {
    UIActivityIndicatorView * indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 4;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - width) / 2;
    CGFloat y = ([UIScreen mainScreen].bounds.size.height - width) / 2;
    indicator.frame = CGRectMake(x, y, width, width);
    [self.view addSubview:indicator];
    [indicator startAnimating];
    btn.enabled = NO;
    [[NetworkMgr sharedManager] uploadTrainDataWithPath:self.filePath Para:@{@"label" : self.label} completeHandler:^(NSError * _Nonnull error, id  _Nonnull response) {
        [indicator removeFromSuperview];
        btn.enabled = YES;
        if (error) {
            [self presentAlertWithMsg:@"Server can not connected!" needPop:NO];
            return ;
        }
        if (response) {
            BOOL code = ([response[@"code"] intValue] == 0 ? YES : NO);
            [self presentAlertWithMsg:response[@"msg"] needPop:code];

        }
    }];
}

- (void)presentAlertWithMsg:(NSString *)msg needPop:(BOOL)flag {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:(UIAlertControllerStyleAlert)];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *showAlert = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        if (flag) {
            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(uploadIsDone:)]){
                [weakSelf.delegate uploadIsDone:YES];
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [alertView addAction:showAlert];
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.playerLayer.frame = self.playerView.bounds;
}

- (void)runLoopTheMovie:(NSNotification *)notification {
    if (notification.object == self.player.currentItem) {
        __weak typeof(self) weakSelf = self;
        [self.player.currentItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.player play];
        }];
    }
}


@end
