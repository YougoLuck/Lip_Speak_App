//
//  TTSMgr.h
//  yzx_tts
//
//  Created by Youmaru on 2019/12/14.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTSMgr : NSObject

@property (nonatomic, copy) NSString *speakText;

+ (instancetype)sharedInstance;
- (void)startSpeak;
@end

NS_ASSUME_NONNULL_END
