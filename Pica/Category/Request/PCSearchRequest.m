//
//  PCSearchRequest.m
//  Pica
//
//  Created by fancy on 2020/11/4.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCSearchRequest.h"
#import <YYModel/YYModel.h>
 
@implementation PCSearchRequest
 
- (instancetype)initWithKeyword:(NSString *)keyword {
    if (self = [super init]) {
        _page = 1;
        _keyword = [keyword copy];
        _sort = @"dd";
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _page = 1;
        _sort = @"dd";
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
    return PC_API_SEARCH_ADVANCED;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"POST" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}
 
- (id)requestArgument {
    NSMutableDictionary *argument = @{@"page" : @(self.page),
                                      @"keyword" : self.keyword}.mutableCopy;
    
    if (self.categories) {
        [argument setObject:self.categories forKey:@"categories"];
    }
    if (self.sort) {
        [argument setObject:self.sort forKey:@"sort"];
    }
    
    return argument;
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 2;
}

- (BOOL)ignoreCache {
    return NO;
}

@end
