//
//  YPreviewView.h
//  lipspeaker
//
//  Created by Youmaru on 2019/11/17.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface YPreviewView : GLKView


- (void)renderWithCImage:(CIImage *)image;


- (void)renderWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
