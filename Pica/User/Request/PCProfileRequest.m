//
//  PCProfileRequest.m
//  Pica
//
//  Created by YueCheng on 2021/5/27.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCProfileRequest.h"
#import <YYModel/YYModel.h>
#import "PCUser.h"

@implementation PCProfileRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCUser *user = [PCUser yy_modelWithJSON:request.responseObject[@"data"][@"user"]];
        !success ? : success(user);
        [[NSUserDefaults standardUserDefaults] setObject:request.responseObject[@"data"][@"user"] forKey:PC_LOCAL_USER];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return PC_API_USERS_PROFILE;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 60;
}

- (BOOL)ignoreCache {
    return NO;
}

@end
