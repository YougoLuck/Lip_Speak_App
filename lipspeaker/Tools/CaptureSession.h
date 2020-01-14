//
//  CaptureSession.h
//  lipspeaker
//
//  Created by Youmaru on 2019/11/16.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "YPreviewView.h"

NS_ASSUME_NONNULL_BEGIN


@class CaptureSession;
@protocol CaptureSessionDelegate <NSObject>
- (CVPixelBufferRef)processVideoCVPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (CMSampleBufferRef)processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;


- (void)sessionStartRecord:(CaptureSession *)captureSession;
- (void)sessionRecordFrame:(CGFloat)currentCnt maxCnt:(CGFloat)maxCnt;
- (void)sessionStopRecord:(CaptureSession *)captureSession filePath:(NSString *)filePath;

@end


@interface CaptureSession : NSObject
@property (weak, nonatomic) id<CaptureSessionDelegate> delegate;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (weak, nonatomic) YPreviewView *preview;

- (instancetype)initWithCropRect:(CGRect)cropRect recordDirectory:(NSString *)dir;

- (void)start;

- (void)stop;

- (void)startRecord;

- (void)stopRecord;

@end

NS_ASSUME_NONNULL_END
