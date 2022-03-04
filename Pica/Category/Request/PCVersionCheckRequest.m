//
//  PCVersionCheckRequest.m
//  Pica
//
//  Created by Fancy on 2022/3/3.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCVersionCheckRequest.h"
#import <YYModel/YYModel.h>

#define PC_API_RELEASE_LATEST   @"https://api.github.com/repos/fanyuecheng/Pica/releases/latest"

@implementation PCVersionCheckRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCVersion *version = [PCVersion yy_modelWithJSON:request.responseJSONObject];
        !success ? : success(version);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        //403 超出请求次数限制
        !failure ? : failure(request.error);
    }];
}

- (NSString *)baseUrl {
    return nil;
}

- (NSString *)requestUrl {
    return PC_API_RELEASE_LATEST;
}

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (BOOL)ignoreCache {
    return YES;
}

@end
