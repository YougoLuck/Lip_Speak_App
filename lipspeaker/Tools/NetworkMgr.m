//
//  NetworkMgr.m
//  lipspeaker
//
//  Created by Youmaru on 2019/11/20.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import "NetworkMgr.h"
#import <AFNetworking/AFNetworking.h>

@interface NetworkMgr ()
@property (nonatomic, strong)AFHTTPSessionManager *sessionMgr;

@end


@implementation NetworkMgr

+ (instancetype)sharedManager
{
    static dispatch_once_t predicate;
    static NetworkMgr *instance = nil;
    
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)setBaseURL:(NSString *)baseURL{
    _baseURL = [NSString stringWithFormat:@"http://%@:55080", baseURL];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.baseURL = @"192.168.123.169";
        AFHTTPSessionManager *sessionMgr = [AFHTTPSessionManager manager];
        AFHTTPResponseSerializer *serializer = sessionMgr.responseSerializer;
        serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html" ,nil];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        sessionMgr.securityPolicy = securityPolicy;
        _sessionMgr = sessionMgr;
    }
    return self;
}

- (void)postWithURL:(NSString *)url para:(NSDictionary *)dict completeHandler:(void (^)(NSError * error, id response))handler{
    [self.sessionMgr POST:url
               parameters:dict
                 progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        handler(nil, responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(error, nil);
    }];
}

- (void)checkServerWithPara:(NSDictionary *)dict completeHandler:(void (^)(NSError * error, id response))handler {
    [self postWithURL:[NSString stringWithFormat:@"%@/%@", self.baseURL, @"checkServer"] para:dict completeHandler:^(NSError * _Nonnull error, id  _Nonnull response) {
        if (error) {
            handler(error, nil);
        } else {
            handler(nil, response);
        }
    }];
}

- (void)uploadTrainDataWithPath:(NSString *)path
                           Para:(NSDictionary *)dict
                completeHandler:(void (^)(NSError * error, id response))handler {
    NSData *movieData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
    NSString *filename = [path lastPathComponent];
    [self.sessionMgr POST:[NSString stringWithFormat:@"%@/%@", self.baseURL, @"uploadTrainData"]
               parameters:dict
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:movieData name:@"file" fileName:filename mimeType:@"mp4/video"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        handler(nil, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(error, nil);
    }];
}

- (void)uploadTestTemDataWithPath:(NSString *)path
                             Para:(NSDictionary *)dict
                  completeHandler:(void (^)(NSError * error, id response))handler {
    NSData *movieData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
    NSString *filename = [path lastPathComponent];
    [self.sessionMgr POST:[NSString stringWithFormat:@"%@/%@", self.baseURL, @"uploadTestTemData"]
               parameters:dict
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:movieData name:@"file" fileName:filename mimeType:@"mp4/video"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        handler(nil, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(error, nil);
    }];
}

@end
