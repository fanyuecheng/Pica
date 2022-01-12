//
//  PCComicEpisodeRequest.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicEpisodeRequest.h"
#import <YYModel/YYModel.h>

@interface PCComicEpisodeRequest ()

@end

@implementation PCComicEpisodeRequest

- (instancetype)initWithComicId:(NSString *)comicId {
    if (self = [super init]) {
        _comicId = [comicId copy];
        _page = 1;
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCComicEpisode *episode = [PCComicEpisode yy_modelWithJSON:request.responseJSONObject[@"data"][@"eps"]]; 
        episode.comicId = [self.comicId copy];
        !success ? : success(episode);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    NSMutableString *requestUrl = [NSMutableString stringWithFormat:PC_API_COMICS_EPS, self.comicId];
    [requestUrl appendFormat:@"?page=%@", @(self.page)];
    return requestUrl;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 60 * 24;
}

- (BOOL)ignoreCache {
    return NO;
}

@end
