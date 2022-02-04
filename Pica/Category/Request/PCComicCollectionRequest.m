//
//  PCComicCollectionRequest.m
//  Pica
//
//  Created by Fancy on 2022/2/4.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCComicCollectionRequest.h"
#import <YYModel/YYModel.h>

@implementation PCComicCollectionRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSArray *collections = [NSArray yy_modelArrayWithClass:[PCComicList class] json:request.responseJSONObject[@"data"][@"collections"]];
        !success ? : success(collections);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return PC_API_COMICS_COLLECTION;
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
