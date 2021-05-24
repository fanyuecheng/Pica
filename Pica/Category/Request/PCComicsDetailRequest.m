//
//  PCComicsDetailRequest.m
//  Pica
//
//  Created by fancy on 2020/11/5.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsDetailRequest.h"
#import <YYModel/YYModel.h>

@implementation PCComicsDetailRequest

- (instancetype)initWithComicsId:(NSString *)comicsId {
    if (self = [super init]) {
        _comicsId = [comicsId copy];
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCComics *comics = [PCComics yy_modelWithJSON:request.responseJSONObject[@"data"][@"comic"]]; 
        !success ? : success(comics);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:PC_API_COMICS_DETAIL, self.comicsId];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}
 
@end
