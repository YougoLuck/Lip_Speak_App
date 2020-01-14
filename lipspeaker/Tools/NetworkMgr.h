//
//  NetworkMgr.h
//  lipspeaker
//
//  Created by Youmaru on 2019/11/20.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkMgr : NSObject

@property (nonatomic, copy) NSString *baseURL;

+ (instancetype)sharedManager;

- (void)postWithURL:(NSString *)url para:(NSDictionary *)dict completeHandler:(void (^)(NSError * error, id response))handler;

- (void)checkServerWithPara:(NSDictionary *)dict completeHandler:(void (^)(NSError * error, id response))handler;
- (void)uploadTrainDataWithPath:(NSString *)path Para:(NSDictionary *)dict completeHandler:(void (^)(NSError * error, id response))handler;
- (void)uploadTestTemDataWithPath:(NSString *)path Para:(NSDictionary *)dict completeHandler:(void (^)(NSError * error, id response))handler;

@end

NS_ASSUME_NONNULL_END
