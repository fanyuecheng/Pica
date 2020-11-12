//
//  PCComicsEpisodeRequest.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsEpisodeRequest.h"
#import <YYModel/YYModel.h>

@interface PCComicsEpisodeRequest ()

@property (nonatomic, assign) NSInteger page;

@end

@implementation PCComicsEpisodeRequest

- (instancetype)initWithComicsId:(NSString *)comicsId {
    if (self = [super init]) {
        _comicsId = [comicsId copy];
        _page = 1;
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCComicsEpisode *episode = [PCComicsEpisode yy_modelWithJSON:request.responseJSONObject[@"data"][@"eps"]]; 
        episode.comicsId = [self.comicsId copy];
        !success ? : success(episode);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"comics/%@/eps?page=%@", self.comicsId, @(self.page)];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

@end
