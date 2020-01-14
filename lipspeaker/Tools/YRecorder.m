//
//  YRecorder.m
//  lipspeaker
//
//  Created by Youmaru on 2019/11/16.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import "YRecorder.h"


@interface YRecorder ()

@property (nonatomic, strong) dispatch_queue_t recordingQueue;
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *assetWriterInputPixelBufferAdaptor;
@property (nonatomic, assign) CGFloat currentFrameCnt;


@end

@implementation YRecorder

- (instancetype)initWithOutputFilePath:(NSString *)path
                           maxFrameCnt:(CGFloat)maxFrameCnt
                        videoFrameRate:(CGFloat)frameRate
                             videoSize:(CGSize)size; {
    self = [super init];
    if (self) {
        _outputPath = path;
        _frameRate = frameRate;
        _maxFrameCnt = maxFrameCnt;
        _videoSize = size;
        [self setupRecorder];
    }
    return self;
}


#pragma mark - Setup Recorder
- (void)setupRecorder {
    
    _onRecording = NO;
    self.recordingQueue = dispatch_queue_create("com.yh.lipspeaker.recordingqueue", DISPATCH_QUEUE_SERIAL);
    [self setupWriterInputs];
    [self resetWriter];
    
}

- (void)setupWriterInputs {
        CGFloat width = self.videoSize.width;
        CGFloat height = self.videoSize.height;
        
        float bitsPerPixel = 4.05;
        int numPixels = width * height;
        int bitsPerSecond = numPixels * bitsPerPixel;

        NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                                 AVVideoExpectedSourceFrameRateKey : @(_frameRate),
                                                 AVVideoMaxKeyFrameIntervalKey : @(_frameRate) };
        
        NSDictionary *videoSettings = @{ AVVideoCodecKey : AVVideoCodecTypeH264,
                                         AVVideoWidthKey : @(width),
                                         AVVideoHeightKey : @(height),
                                         AVVideoCompressionPropertiesKey : compressionProperties };
        
        self.assetWriterVideoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                    outputSettings:videoSettings];
        self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        
        //WriterAudioInput
        NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                  [ NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                  [ NSNumber numberWithFloat: 44100], AVSampleRateKey,
                                  nil];
        self.assetWriterAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                                                    outputSettings:audioSettings];
        self.assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        
    
        //WriterInputPixelBufferAdaptor
        NSDictionary *attributes = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                     (id)kCVPixelBufferWidthKey : videoSettings[AVVideoWidthKey],
                                     (id)kCVPixelBufferHeightKey : videoSettings[AVVideoHeightKey],
                                     };
        self.assetWriterInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc]
                                                   initWithAssetWriterInput:self.assetWriterVideoInput
                                                   sourcePixelBufferAttributes:attributes];
    }

- (BOOL)resetOutputFilePath:(NSString *)path {
    if (_onRecording) {
        return NO;
    }
    _outputPath = path;
    [self resetWriter];
    return YES;
}

- (void)resetWriter {
    _currentFrameCnt = 0;
    NSError *error = nil;
    self.assetWriter = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:_outputPath]
                                                fileType:AVFileTypeMPEG4
                                                   error:&error];
    self.assetWriter.shouldOptimizeForNetworkUse = YES;
    if (self.assetWriter && !error) {
        if ([self.assetWriter canAddInput:self.assetWriterVideoInput]) {
            [self.assetWriter addInput:self.assetWriterVideoInput];
        }
        
        if ([self.assetWriter canAddInput:self.assetWriterAudioInput]) {
            [self.assetWriter addInput:self.assetWriterAudioInput];
        }
    }
}

- (BOOL)startRecord {
    if (self.onRecording) {
        return NO;
    }
    _onRecording = YES;
    return YES;
}

- (BOOL)stopRecord {
    if (!self.onRecording) {
        return NO;
    }
    _onRecording = NO;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.recordingQueue,^() {
        if (weakSelf.assetWriter && weakSelf.assetWriter.status == AVAssetWriterStatusWriting) {
            [weakSelf.assetWriterVideoInput markAsFinished];
            [weakSelf.assetWriterAudioInput markAsFinished];
            [weakSelf.assetWriter finishWritingWithCompletionHandler:^{
                if(weakSelf.delegate &&
                    [weakSelf.delegate respondsToSelector:@selector(recorderStopRecord:filePath:)]){
                    [weakSelf.delegate recorderStopRecord:weakSelf filePath:(NSString *)weakSelf.outputPath];
                }
            }];
        }
    });
    return YES;
}

#pragma mark - Record
- (void)appendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime {
    if (!self.onRecording) {
        return;
    }
    
    if (self.currentFrameCnt >= self.maxFrameCnt) {
        [self stopRecord];
    }
    __weak typeof(self) weakSelf = self;
    CVPixelBufferRetain(pixelBuffer);
    dispatch_async(self.recordingQueue, ^{
        if (weakSelf.assetWriter.status == AVAssetWriterStatusUnknown) {
            if ([weakSelf.assetWriter startWriting]) {
                [weakSelf.assetWriter startSessionAtSourceTime:presentationTime];
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(recorderStartRecord:)]){
                    [weakSelf.delegate recorderStartRecord:weakSelf];
                }
            } else {
                NSLog(@"Failed to start writing.");
            }
        }
        
        if (weakSelf.assetWriter.status == AVAssetWriterStatusWriting &&
            weakSelf.assetWriterVideoInput.readyForMoreMediaData &&
            pixelBuffer) {
            
            if ([weakSelf.assetWriterInputPixelBufferAdaptor appendPixelBuffer:pixelBuffer
                                                           withPresentationTime:presentationTime]) {
                weakSelf.currentFrameCnt += 1;
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(recorderRecordFrame:maxCnt:)]){
                    [weakSelf.delegate recorderRecordFrame:weakSelf.currentFrameCnt maxCnt:weakSelf.maxFrameCnt];
                }
            } else {
                NSLog(@"Error appending pixel buffer.");
            }
        }
        CVPixelBufferRelease(pixelBuffer);
    });

}

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (!self.onRecording) {
        return;
    }
    CFRetain(sampleBuffer);
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.recordingQueue, ^{
        
        if (weakSelf.assetWriter.status == AVAssetWriterStatusWriting &&
            weakSelf.assetWriterAudioInput.readyForMoreMediaData &&
            sampleBuffer) {
            
            if (![weakSelf.assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                NSLog(@"Error appending audio buffer.");
            }
        }
        CFRelease(sampleBuffer);
    });
}

@end
