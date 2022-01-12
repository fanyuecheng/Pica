//
//  PCLikeRequest.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCLikeRequest.h"

@interface PCLikeRequest ()

@property (nonatomic, copy)   NSString *objectId;
@property (nonatomic, assign) BOOL  isComic;

@end

@implementation PCLikeRequest

- (instancetype)initWithComicId:(NSString *)comicId {
    if (self = [super init]) {
        _objectId = [comicId copy];
        _isComic = YES;
    }
    return self;
}

- (instancetype)initWithGameId:(NSString *)gameId {
    if (self = [super init]) {
        _objectId = [gameId copy];
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSString *action = request.responseJSONObject[@"data"][@"action"];
        NSNumber *like = [action isEqualToString:@"like"] ? @1 : @0;
        !success ? : success(like);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return self.isComic ? [NSString stringWithFormat:PC_API_COMICS_LIKE, self.objectId] : [NSString stringWithFormat:PC_API_GAME_LIKE, self.objectId];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"POST" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

@end
