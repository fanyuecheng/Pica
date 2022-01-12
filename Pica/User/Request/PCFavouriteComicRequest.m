//
//  PCFavouriteComicRequest.m
//  Pica
//
//  Created by YueCheng on 2021/5/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCFavouriteComicRequest.h"
#import "PCComic.h"
#import <YYModel/YYModel.h>

@implementation PCFavouriteComicRequest

- (instancetype)init {
    if (self = [super init]) {
        self.page = 1;
        self.s = @"dd";
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCComicList *list = [PCComicList yy_modelWithJSON:request.responseJSONObject[@"data"][@"comics"]];
        !success ? : success(list);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:PC_API_USERS_FAVOURITE, self.s, @(self.page)];
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

