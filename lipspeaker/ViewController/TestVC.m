//
//  TestVC.m
//  lipspeaker
//
//  Created by Youmaru on 2019/12/15.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import "TestVC.h"
#import "CaptureSession.h"
#import "FileMgr.h"
#import "NetworkMgr.h"
#import <Masonry/Masonry.h>
#import "TTSMgr.h"

@interface TestVC ()<CaptureSessionDelegate>
@property (strong, nonatomic) CaptureSession *captureSession;
@property (weak,   nonatomic) UIButton *recordBtn;
@property (weak,   nonatomic) UIButton *retakeBtn;
@property (weak,   nonatomic) UIButton *uploadBtn;
@property (weak,   nonatomic) UIProgressView *progress;
@property (weak,   nonatomic) YPreviewView *preview;
@property (copy,   nonatomic) NSString *outputFilePath;
@property (assign, nonatomic) CGSize videoSize;
@end

@implementation TestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setupCamera];
    [self setupProgressAndRecordBtnAndRetake];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.captureSession start];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.captureSession stop];
    [self.captureSession stopRecord];
}

- (void)setupCamera {
    CGRect corpRect = CGRectMake(400, 470, 400, 260);
    self.videoSize = corpRect.size;
    self.captureSession = [[CaptureSession alloc] initWithCropRect:corpRect
                                                   recordDirectory:[[FileMgr shareMgr] moviePath]];
    YPreviewView *preview = [[YPreviewView alloc] init];
    self.captureSession.delegate = self;
    [self.view addSubview:preview];
    
    __weak typeof(self) weakSelf = self;
    [preview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(67);
        make.centerX.equalTo(weakSelf.view);
        make.left.equalTo(weakSelf.view).offset(30);
        make.right.equalTo(weakSelf.view).offset(-30);
        make.height.equalTo(preview.mas_width).multipliedBy(corpRect.size.height / corpRect.size.width);
    }];
    self.preview = preview;
    self.captureSession.preview = preview;
    [self.captureSession start];
}


- (void)setupProgressAndRecordBtnAndRetake {
    
    __weak typeof(self) weakSelf = self;
    UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:progress];
    [progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.preview.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.preview);
        make.right.equalTo(weakSelf.preview);
        make.height.equalTo(@(20));
    }];
    self.progress = progress;
    progress.progress = 0;
    
    UIButton *recordBtn = [[UIButton alloc] init];
    [recordBtn setTitle:@"Record" forState:UIControlStateNormal];
    [recordBtn setTitle:@"Recording" forState:UIControlStateDisabled];
    [recordBtn setBackgroundColor:[UIColor orangeColor]];
    recordBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    recordBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    recordBtn.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;
    [recordBtn addTarget:self action:@selector(clickRecordBtn) forControlEvents:UIControlEventTouchUpInside];
    self.recordBtn = recordBtn;
    [self.view addSubview:recordBtn];
    [recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progress.mas_bottom).offset(5);
        make.left.equalTo(weakSelf.preview);
        make.right.equalTo(weakSelf.preview);
        make.height.equalTo(@(40));
    }];
    
    UIButton *retakeBtn = [[UIButton alloc] init];
    [retakeBtn setTitle:@"Retake" forState:UIControlStateNormal];
    retakeBtn.hidden = YES;
    [retakeBtn setBackgroundColor:[UIColor orangeColor]];
    retakeBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    retakeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    retakeBtn.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;
    [retakeBtn addTarget:self action:@selector(clickRetakeBtn) forControlEvents:UIControlEventTouchUpInside];
    self.retakeBtn = retakeBtn;
    [self.view addSubview:retakeBtn];
    [retakeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(recordBtn.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.preview);
        make.right.equalTo(weakSelf.preview);
        make.height.equalTo(@(40));
    }];
    
    UIButton *uploadBtn = [[UIButton alloc] init];
    [uploadBtn setTitle:@"Upload" forState:UIControlStateNormal];
    uploadBtn.hidden = YES;
    [uploadBtn setBackgroundColor:[UIColor orangeColor]];
    uploadBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    uploadBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    uploadBtn.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;
    [uploadBtn addTarget:self action:@selector(clickUploadBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.uploadBtn = uploadBtn;
    [self.view addSubview:uploadBtn];
    [uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(retakeBtn.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.preview);
        make.right.equalTo(weakSelf.preview);
        make.height.equalTo(@(40));
    }];
}

- (void)clickRecordBtn {
    self.recordBtn.enabled = NO;
    [self.captureSession startRecord];
}

- (void)clickRetakeBtn {
    self.outputFilePath = nil;
    self.progress.progress = 0;
    self.retakeBtn.hidden = YES;
    self.uploadBtn.hidden = YES;
    self.recordBtn.enabled = YES;
    [self.retakeBtn setTitle:@"Recording" forState:UIControlStateDisabled];
}

- (void)clickUploadBtn:(UIButton *)btn {
    btn.enabled = NO;
    [[NetworkMgr sharedManager] uploadTestTemDataWithPath:self.outputFilePath Para:@{} completeHandler:^(NSError * _Nonnull error, id  _Nonnull response) {
        btn.enabled = YES;
        if (error) {
            [self presentAlertWithMsg:@"Server can not connected!" needPop:NO];
            return ;
        }
        
        if (response) {
            NSString *result = [response[@"result"] firstObject];
            [TTSMgr sharedInstance].speakText = result;
            [[TTSMgr sharedInstance] startSpeak];
            
        }
    }];
}

- (void)presentAlertWithMsg:(NSString *)msg needPop:(BOOL)flag {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:(UIAlertControllerStyleAlert)];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *showAlert = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        if (flag) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [alertView addAction:showAlert];
    [self presentViewController:alertView animated:YES completion:nil];
}

- (CVPixelBufferRef)processVideoCVPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    return pixelBuffer;
}

- (CMSampleBufferRef)processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    return sampleBuffer;
}

- (void)sessionStartRecord:(CaptureSession *)captureSession {

}

- (void)sessionRecordFrame:(CGFloat)currentCnt maxCnt:(CGFloat)maxCnt {
    self.progress.progress = currentCnt/maxCnt;
}

- (void)sessionStopRecord:(CaptureSession *)captureSession filePath:(NSString *)filePath {
    self.outputFilePath = filePath;
    self.retakeBtn.hidden = NO;
    self.uploadBtn.hidden = NO;
    [self.recordBtn setTitle:@"Record Done" forState:UIControlStateDisabled];
}


@end
