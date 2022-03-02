//
//  PCComicSimilarRequest.m
//  Pica
//
//  Created by Fancy on 2022/3/1.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCComicSimilarRequest.h"
#import <YYModel/YYModel.h>
#import "PCComic.h"
 
@implementation PCComicSimilarRequest

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
        NSArray *comics = [NSArray yy_modelArrayWithClass:PCComic.class json:request.responseJSONObject[@"data"][@"comics"]];
        !success ? : success(comics);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:PC_API_COMICS_RECOMMENDATION, self.comicId];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}
 
@end
