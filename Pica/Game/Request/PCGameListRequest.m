//
//  PCGameListRequest.m
//  Pica
//
//  Created by Fancy on 2021/6/25.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCGameListRequest.h"
#import "PCGame.h"
#import <YYModel/YYModel.h>

@implementation PCGameListRequest

- (instancetype)init {
    if (self = [super init]) {
        self.page = 1;
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCGameList *list = [PCGameList yy_modelWithJSON:request.responseJSONObject[@"data"][@"games"]];
        !success ? : success(list);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:PC_API_GAME_LIST, @(self.page)];
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
