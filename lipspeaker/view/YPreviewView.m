//
//  YPreviewView.m
//  lipspeaker
//
//  Created by Youmaru on 2019/11/17.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import "YPreviewView.h"

@interface YPreviewView()
@property (strong, nonatomic) CIContext *ciContext;
@property (strong, nonatomic) CIImage *displayImage;

@end

@implementation YPreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:nil];
        self.ciContext = [CIContext contextWithEAGLContext:self.context];
        
    }
    return self;
}

- (void)renderWithCImage:(CIImage *)image {
    self.displayImage = image;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf setNeedsDisplay];
    });
        
}


- (void)renderWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    if (image) {
        [self renderWithCImage:image];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (self.displayImage) {
        CGAffineTransform scale = CGAffineTransformMakeScale(self.contentScaleFactor,
                                                             self.contentScaleFactor);
        CGRect rectDraw = CGRectApplyAffineTransform(self.bounds, scale);
//        CGSize imgSize = [self.displayImage extent].size;
//        CGRect rectDraw = CGRectMake(0, 0, imgSize.width, imgSize.height);
        [self.ciContext drawImage:self.displayImage inRect:rectDraw fromRect:[self.displayImage extent]];
        
        glFlush();
    }
}

@end
