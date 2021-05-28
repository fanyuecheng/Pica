//
//  PCKnightRankRequest.m
//  Pica
//
//  Created by YueCheng on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCKnightRankRequest.h"
#import <YYModel/YYModel.h>
#import "PCUser.h"

@implementation PCKnightRankRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSArray *list = [NSArray yy_modelArrayWithClass:[PCUser class] json:request.responseJSONObject[@"data"][@"users"]];
        !success ? : success(list);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (NSString *)requestUrl { 
    return PC_API_COMICS_KNIGHT;
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 60;
}

- (BOOL)ignoreCache {
    return NO;
}

@end
