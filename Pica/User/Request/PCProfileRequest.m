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
        if (!self.userId) {
            [kPCUserDefaults setObject:request.responseObject[@"data"][@"user"] forKey:PC_LOCAL_USER];
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return self.userId ? [NSString stringWithFormat:PC_API_USERS_PROFILE, self.userId] : PC_API_USERS_PROFILE_ME;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (BOOL)ignoreCache {
    return YES;
}

@end
