//
//  YRecorder.h
//  lipspeaker
//
//  Created by Youmaru on 2019/11/16.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@class YRecorder;
@protocol YRecorderDelegate <NSObject>
- (void)recorderStartRecord:(YRecorder *)recorder;
- (void)recorderRecordFrame:(CGFloat)currentCnt maxCnt:(CGFloat)maxCnt;
- (void)recorderStopRecord:(YRecorder *)recorder filePath:(NSString *)filePath;
@end

@interface YRecorder : NSObject

@property (nonatomic, assign, readonly) BOOL onRecording;
@property (nonatomic, copy,   readonly) NSString *outputPath;
@property (nonatomic, assign, readonly) CGFloat maxFrameCnt;
@property (nonatomic, assign, readonly) CGFloat frameRate;
@property (nonatomic, assign, readonly) CGSize videoSize;
@property (nonatomic, weak) id<YRecorderDelegate> delegate;

- (instancetype)initWithOutputFilePath:(NSString *)path
                           maxFrameCnt:(CGFloat)maxFrameCnt
                        videoFrameRate:(CGFloat)frameRate
                             videoSize:(CGSize)size;

- (void)appendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime;

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (BOOL)startRecord;

- (BOOL)stopRecord;

- (BOOL)resetOutputFilePath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
