//
//  UploadVC.h
//  lipspeaker
//
//  Created by Youmaru on 2019/11/18.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol UploadVCDelegate <NSObject>
- (void)uploadIsDone:(BOOL)flag;
@end

@interface UploadVC : UIViewController
@property (nonatomic, weak) id<UploadVCDelegate> delegate;

- (instancetype)initWithVideoSize:(CGSize)size
                         filePath:(NSString *)path
                            label:(NSString *)label;


@end

NS_ASSUME_NONNULL_END
