//
//  CaptureSession.m
//  lipspeaker
//
//  Created by Youmaru on 2019/11/16.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import "CaptureSession.h"
#import "FileMgr.h"
#import "YRecorder.h"

@interface CaptureSession()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, YRecorderDelegate>

@property (strong, nonatomic) AVCaptureDevice *inputCamera;
@property (strong, nonatomic) AVCaptureDevice *inputMicphone;
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureDeviceInput *audioInput;
@property (strong, nonatomic) AVCaptureAudioDataOutput *audioDataOutput;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) AVCaptureSessionPreset capturePresent;
@property (strong, nonatomic) YRecorder *recorder;
@property (assign, nonatomic) CGFloat frameRate;
@property (assign, nonatomic) CGRect cropRect;
@property (strong, nonatomic) CIContext *context;
@property (copy,   nonatomic) NSString *recordDir;
@end

@implementation CaptureSession

-(instancetype)init{
    if((self = [super init])){
        self = [self initWithCropRect:CGRectZero recordDirectory:[[FileMgr shareMgr] moviePath]];
    }
    return self;
}

- (instancetype)initWithCropRect:(CGRect)cropRect recordDirectory:(NSString *)dir{
    if((self = [super init])){
        if (CGRectIsEmpty(cropRect)) {
            self.cropRect = CGRectMake(0, 0, 1080, 1920);
        } else {
            self.cropRect = cropRect;
        }
        self.recordDir = dir;
        self.context = [CIContext contextWithOptions:nil];
        dispatch_queue_t videoCaptureQueue = dispatch_queue_create("com.yh.lipspeaker.videocapturequeue", NULL);
        dispatch_queue_t audioCaptureQueue = dispatch_queue_create("com.yh.lipspeaker.audiocapturequeue", NULL);
        self.frameRate = 25;
        
        self.captureSession = [[AVCaptureSession alloc]init];
        if([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]){
            [self.captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
            self.capturePresent = AVCaptureSessionPreset1920x1080;
        }
        
        
        self.inputCamera = [self cameraWithPostion:AVCaptureDevicePositionFront];
        CMTime scaele = CMTimeMake(1, self.frameRate);
        [self.inputCamera lockForConfiguration:nil];
        self.inputCamera.activeVideoMaxFrameDuration= scaele;
        self.inputCamera.activeVideoMinFrameDuration= scaele;
        [self.inputCamera unlockForConfiguration];
        
        [self.captureSession beginConfiguration];

        NSError *error = nil;
        self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.inputCamera error:&error];
        if(error){
            NSLog(@"Camera error");
            return nil;
        }
        
        //add video input to AVCaptureSession
        if([self.captureSession canAddInput:self.videoInput]){
            [self.captureSession addInput:self.videoInput];
        }
        
        //initialize an AVCaptureVideoDataOuput instance
        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
        [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:NO];
        [self.videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        
        [self.videoDataOutput setSampleBufferDelegate:self queue:videoCaptureQueue];
        
        //add video data output to capture session
        if([self.captureSession canAddOutput:self.videoDataOutput]){
            [self.captureSession addOutput:self.videoDataOutput];
        }
        
        //setting orientaion
        AVCaptureConnection *connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        connection.videoScaleAndCropFactor = connection.videoMaxScaleAndCropFactor;
        
        
        error = nil;
        //get an AVCaptureDevice for audio, here we want micphone
        self.inputMicphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        
        //intialize the AVCaputreDeviceInput instance with micphone device
        self.audioInput =[[AVCaptureDeviceInput alloc]initWithDevice:_inputMicphone error:&error];
        if(error){
            NSLog(@"micphone error");
        }
        
        //add audio device input to capture session
        if([self.captureSession canAddInput:_audioInput]){
            [self.captureSession addInput:_audioInput];
        }
        
        //initliaze an AVCaptureAudioDataOutput instance and set to
        self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
        if([self.captureSession canAddOutput:self.audioDataOutput]){
            [self.captureSession addOutput:self.audioDataOutput];
        }
        
        [self.audioDataOutput setSampleBufferDelegate:self queue:audioCaptureQueue];
        [self.captureSession commitConfiguration];
        
        [self setupRecorder];
    }
    return self;
}

- (AVCaptureDevice *)cameraWithPostion:(AVCaptureDevicePosition)position{
    AVCaptureDeviceDiscoverySession *devicesArr = [AVCaptureDeviceDiscoverySession  discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo  position:position];
    
    NSArray *devices  = devicesArr.devices;
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (void)setupRecorder {
    self.recorder = [[YRecorder alloc] initWithOutputFilePath:[[FileMgr shareMgr] generateMoviePathWithPath:self.recordDir]
                                                  maxFrameCnt:75
                                               videoFrameRate:self.frameRate
                                                    videoSize:self.cropRect.size];
    self.recorder.delegate = self;
}



- (void)start{
    if (!self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)stop{
    if (!self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }
}

- (void)startRecord {
    [self.recorder startRecord];
}

- (void)stopRecord {
    [self.recorder stopRecord];
}

#pragma mark - delegate
-(void) captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    //Video
    if(output == self.videoDataOutput){
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(processVideoCVPixelBuffer:)]){
            pixelBuffer = [self.delegate processVideoCVPixelBuffer:pixelBuffer];
        }
        CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        
        image = [image imageByApplyingCGOrientation: kCGImagePropertyOrientationUpMirrored];
        image = [image imageByCroppingToRect:self.cropRect];
        image = [image imageByApplyingTransform:CGAffineTransformMakeTranslation(-image.extent.origin.x, -image.extent.origin.y)];
        CGSize imgSize = image.extent.size;
        //转换镜像,裁剪
        [self.preview renderWithCImage:image];


        
        //转换pixelbuffer
        CVPixelBufferRef pxbuffer = NULL;
        NSDictionary *options = @{
                          (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                          (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                          };
        
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                              imgSize.width,
                                              imgSize.height,
                                              kCVPixelFormatType_32BGRA,
                                              (__bridge CFDictionaryRef) options,
                                              &pxbuffer);
        if (status == kCVReturnSuccess) {
            [self.context render:image toCVPixelBuffer:pxbuffer];
        }
        [self.recorder appendVideoPixelBuffer:pxbuffer withPresentationTime:timestamp];
        CVPixelBufferRelease(pxbuffer);
    
    //Audio
    }else if(output == self.audioDataOutput){
        
        if(self.delegate &&[self.delegate respondsToSelector:@selector(processAudioSampleBuffer:)]){
            sampleBuffer = [self.delegate processAudioSampleBuffer:sampleBuffer];
        }
        [self.recorder appendAudioSampleBuffer:sampleBuffer];
    }
}

- (void)recorderStartRecord:(YRecorder *)recorder {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf.delegate &&[weakSelf.delegate respondsToSelector:@selector(sessionStartRecord:)]){
            [weakSelf.delegate sessionStartRecord:weakSelf];
        }
    });
}
- (void)recorderRecordFrame:(CGFloat)currentCnt maxCnt:(CGFloat)maxCnt {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
    if(weakSelf.delegate &&[weakSelf.delegate respondsToSelector:@selector(sessionRecordFrame:maxCnt:)]){
        [weakSelf.delegate sessionRecordFrame:currentCnt maxCnt:maxCnt];
    }
    });
}
- (void)recorderStopRecord:(YRecorder *)recorder filePath:(NSString *)filePath {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf.delegate &&[weakSelf.delegate respondsToSelector:@selector(sessionStopRecord:filePath:)]){
            [weakSelf.delegate sessionStopRecord:weakSelf filePath:filePath];
        }
    });
    [self.recorder resetOutputFilePath:[[FileMgr shareMgr] generateMoviePathWithPath:self.recordDir]];
    
}
@end
