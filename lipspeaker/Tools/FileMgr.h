//
//  FileMgr.h
//  lipspeaker
//
//  Created by Youmaru on 2019/11/17.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileMgr : NSObject

+ (instancetype)shareMgr;

- (NSString *)moviePath;
- (NSString *)packagePath;
- (NSString *)generateMoviePath;
- (NSString *)generateMoviePathWithPath:(NSString *)path;

- (void)removeDir:(NSString *)dir;
@end

NS_ASSUME_NONNULL_END
