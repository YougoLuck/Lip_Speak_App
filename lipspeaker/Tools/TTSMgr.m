//
//  TTSMgr.m
//  yzx_tts
//
//  Created by Youmaru on 2019/12/14.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import "TTSMgr.h"
#import <AVFoundation/AVFoundation.h>

@interface TTSMgr()<AVSpeechSynthesizerDelegate>
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@property (nonatomic, strong) AVSpeechUtterance *utterance;

@end


@implementation TTSMgr

- (instancetype)init
{
    self = [super init];
    if (self) {
        _synthesizer = [[AVSpeechSynthesizer alloc]init];
        _synthesizer.delegate = self;
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static TTSMgr *manager;
    dispatch_once(&once, ^{
        manager = [[TTSMgr alloc]init];
    });
    
    return manager;
}

- (void)setSpeakText:(NSString *)speakText{
    if (speakText != _speakText) {
        _speakText = speakText;
        _utterance = [AVSpeechUtterance speechUtteranceWithString:speakText];
        [self setUtterance];
    }
}

- (void)setUtterance
{
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"ja-JP"];
    _utterance.voice = voice;
    _utterance.rate = AVSpeechUtteranceDefaultSpeechRate;//速率
    _utterance.pitchMultiplier = 1;//音调
    _utterance.volume = 3;//音量
    _utterance.preUtteranceDelay = 0;//朗读本句前延迟
    _utterance.postUtteranceDelay = 0;//朗读本句后延迟
}

- (void)startSpeak {
    if (_synthesizer.isSpeaking || _synthesizer.isPaused) {
        [_synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }else{
        [_synthesizer speakUtterance:_utterance];
    }
}

@end
