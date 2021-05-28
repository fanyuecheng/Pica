//
//  PCComicsPictureRequest.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsPictureRequest.h"
#import <YYModel/YYModel.h>

@interface PCComicsPictureRequest ()
  
@end

@implementation PCComicsPictureRequest

- (instancetype)initWithComicsId:(NSString *)comicsId
                           order:(NSInteger)order  {
    if (self = [super init]) {
        _comicsId = [comicsId copy];
        _order = order;
        _page = 1;
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCEpisodePicture *picture = [PCEpisodePicture yy_modelWithJSON:request.responseJSONObject[@"data"][@"pages"]];
        !success ? : success(picture);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    NSMutableString *requestUrl = [NSMutableString stringWithFormat:PC_API_COMICS_IMAGE, self.comicsId, @(self.order)];
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
    return 60 * 60 * 24 * 30;
}

- (BOOL)ignoreCache {
    return NO;
}

@end
