//
//  PCComicDetailRequest.m
//  Pica
//
//  Created by fancy on 2020/11/5.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicDetailRequest.h"
#import <YYModel/YYModel.h>

@implementation PCComicDetailRequest

- (instancetype)initWithComicId:(NSString *)comicId {
    if (self = [super init]) {
        _comicId = [comicId copy];
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCComic *comic = [PCComic yy_modelWithJSON:request.responseJSONObject[@"data"][@"comic"]];
        !success ? : success(comic);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:PC_API_COMICS_DETAIL, self.comicId];
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
