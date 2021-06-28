//
//  PCGameDetailRequest.m
//  Pica
//
//  Created by Fancy on 2021/6/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCGameDetailRequest.h"
#import "PCGame.h"
#import <YYModel/YYModel.h>

@implementation PCGameDetailRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCGame *game = [PCGame yy_modelWithJSON:request.responseJSONObject[@"data"][@"game"]];
        !success ? : success(game);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:PC_API_GAME_DETAIL, self.gameId];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 60 * 24 * 30;
}

- (BOOL)ignoreCache {
    return NO;
}


@end
