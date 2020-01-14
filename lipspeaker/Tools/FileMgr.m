//
//  FileMgr.m
//  lipspeaker
//
//  Created by Youmaru on 2019/11/17.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import "FileMgr.h"

@implementation FileMgr


static FileMgr* _instance = nil;

+ (instancetype)shareMgr {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    
    return _instance ;
}

- (NSString *)packagePath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *packagePath = [NSString stringWithFormat:@"%@/com.yh.lipspeaker", documentsPath];
    BOOL isDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:packagePath isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:packagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return packagePath;
}

- (NSString *)moviePath {
    
    NSString *packagePath = [self packagePath];
    NSString *moviePath = [packagePath stringByAppendingPathComponent:@"trainData"];
    BOOL isDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:moviePath isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:moviePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return moviePath;
}


- (NSString *)generateMoviePath {
    return [self generateMoviePathWithPath:[self moviePath]];
}


- (NSString *)generateMoviePathWithPath:(NSString *)path {
     NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"yyyyMMddhhmmss"];
    NSString *theTime = [timeFormat stringFromDate:[NSDate date]];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@%d.mp4", path, theTime, arc4random_uniform(10)];
    unlink([filePath UTF8String]);
     return filePath;
}

- (void)removeDir:(NSString *)dir {
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:dir] error:nil];
}
@end
