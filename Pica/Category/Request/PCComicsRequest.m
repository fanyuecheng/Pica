//
//  PCComicsRequest.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsRequest.h"
#import <YYModel/YYModel.h>

@implementation PCComicsRequest

- (instancetype)init {
    if (self = [super init]) {
        _page = 1;
        _s = @"dd";
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCComicsList *list = [PCComicsList yy_modelWithJSON:request.responseJSONObject[@"data"][@"comics"]]; 
        !success ? : success(list);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    NSMutableString *requestUrl = [NSMutableString stringWithFormat:@"comics?page=%@&s=%@", @(self.page), self.s];
    if (self.c) {
        [requestUrl appendFormat:@"&c=%@", self.c];
    }
    if (self.t) {
        [requestUrl appendFormat:@"&t=%@", self.t];
    }
    return [requestUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}
 
@end
