//
//  CollectVC.m
//  lipspeaker
//
//  Created by Youmaru on 2019/11/15.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import "CollectVC.h"
#import "CaptureSession.h"
#import "FileMgr.h"
#import "UploadVC.h"
#import <Masonry/Masonry.h>

@interface CollectVC ()<CaptureSessionDelegate, UploadVCDelegate>
@property (strong, nonatomic) CaptureSession *captureSession;
@property (strong, nonatomic) NSMutableArray *words;
@property (weak,   nonatomic) UILabel *wordsLabel;
@property (weak,   nonatomic) UIButton *resetBtn;
@property (weak,   nonatomic) UIButton *recordBtn;
@property (weak,   nonatomic) UIButton *retakeBtn;
@property (weak,   nonatomic) UIButton *uploadBtn;
@property (weak,   nonatomic) UIProgressView *progress;
@property (weak,   nonatomic) YPreviewView *preview;
@property (copy,   nonatomic) NSString *outputFilePath;
@property (assign, nonatomic) CGSize videoSize;

@end

@implementation CollectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setupWords];
    [self setupCamera];
    [self setupRandomWordsAndResetBtn];
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


- (void)setupWords {
    NSArray *words = @[@[@"ばす", @"ちかてつ", @"ひこうき", @"くるま", @"ばいく"],
                        @[@"ごはん", @"にく", @"さかな", @"ぽてと", @"やさい"],
                       @[@"しながわ", @"よこはま", @"しぶや", @"ぎんざ", @"うえの"]];
    NSMutableArray *mWords = [NSMutableArray array];
    for (NSArray *arr in words) {
        [mWords addObject:[NSMutableArray arrayWithArray:arr]];
    }
    self.words = mWords;
}

- (NSString *)generateRandomWords:(int)cnt{
    NSMutableArray *words = [NSMutableArray arrayWithArray:self.words];
    NSMutableArray *pickWords = [NSMutableArray array];
    
    while (pickWords.count < cnt) {
        int x = arc4random_uniform(3);
        int y = arc4random_uniform(5);

        NSString *word = words[x][y];
        if (![pickWords containsObject:word]) {
            [pickWords addObject:word];
        }
    }
    return [pickWords componentsJoinedByString:@" "];
}

- (void)setupRandomWordsAndResetBtn {
    UILabel *wordsLabel = [[UILabel alloc] init];
    wordsLabel.textColor = [UIColor blackColor];
    wordsLabel.text = [self generateRandomWords:2];
    wordsLabel.font = [UIFont boldSystemFontOfSize:20];
    wordsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:wordsLabel];
    self.wordsLabel = wordsLabel;
    __weak typeof(self) weakSelf = self;
    [wordsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.preview.mas_bottom).offset(5);
        make.left.equalTo(weakSelf.preview);
        make.right.equalTo(weakSelf.preview);
        make.height.equalTo(@(30));
    }];
    
    UIButton *resetBtn = [[UIButton alloc] init];
    [resetBtn setTitle:@"Reset" forState:UIControlStateNormal];
    [resetBtn setBackgroundColor:[UIColor orangeColor]];
    resetBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    resetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    resetBtn.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;
    [resetBtn addTarget:self action:@selector(clickRest) forControlEvents:UIControlEventTouchUpInside];
    self.resetBtn = resetBtn;
    [self.view addSubview:resetBtn];
    [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wordsLabel.mas_bottom).offset(5);
        make.left.equalTo(weakSelf.preview);
        make.right.equalTo(weakSelf.preview);
        make.height.equalTo(@(40));
    }];
}

- (void)setupProgressAndRecordBtnAndRetake {
    
    __weak typeof(self) weakSelf = self;
    UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:progress];
    [progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.resetBtn.mas_bottom).offset(15);
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
    [uploadBtn addTarget:self action:@selector(clickUploadBtn) forControlEvents:UIControlEventTouchUpInside];
    self.uploadBtn = uploadBtn;
    [self.view addSubview:uploadBtn];
    [uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(retakeBtn.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.preview);
        make.right.equalTo(weakSelf.preview);
        make.height.equalTo(@(40));
    }];
}


- (void)clickRest {
    self.wordsLabel.text = [self generateRandomWords:2];
}


- (void)clickRecordBtn {
    self.resetBtn.hidden = YES;
    self.recordBtn.enabled = NO;
    [self.captureSession startRecord];
}

- (void)clickRetakeBtn {
    self.outputFilePath = nil;
    self.progress.progress = 0;
    self.retakeBtn.hidden = YES;
    self.resetBtn.hidden = NO;
    self.uploadBtn.hidden = YES;
    self.recordBtn.enabled = YES;
    [self.retakeBtn setTitle:@"Recording" forState:UIControlStateDisabled];
}

- (void)clickUploadBtn {
    UploadVC *vc = [[UploadVC alloc] initWithVideoSize:self.videoSize filePath:self.outputFilePath label:self.wordsLabel.text];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)uploadIsDone:(BOOL)flag {
    if (flag) {
        [self clickRest];
        [self clickRetakeBtn];
    }
}

@end
