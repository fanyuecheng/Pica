//
//  PCCommentLikeRequest.m
//  Pica
//
//  Created by Fancy on 2021/6/4.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCCommentLikeRequest.h"

@implementation PCCommentLikeRequest

- (instancetype)initWithCommentId:(NSString *)commentId {
    if (self = [super init]) {
        _commentId = [commentId copy];
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSString *action = request.responseObject[@"data"][@"action"];
        NSNumber *isLike = [NSNumber numberWithBool:[action isEqualToString:@"like"]];
        !success ? : success(isLike);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:PC_API_COMICS_COMMENTS_LIKE, self.commentId];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"POST" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (BOOL)ignoreCache {
    return YES;
}

@end
