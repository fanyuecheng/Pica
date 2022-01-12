//
//  PCComicFavouriteRequest.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicFavouriteRequest.h"

@implementation PCComicFavouriteRequest

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
        NSString *action = request.responseJSONObject[@"data"][@"action"];
        NSNumber *favourite = [action isEqualToString:@"favourite"] ? @1 : @0;
        !success ? : success(favourite);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:PC_API_COMICS_FAVOURITE, self.comicId];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"POST" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

@end
