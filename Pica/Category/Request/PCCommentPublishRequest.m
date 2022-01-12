//
//  PCCommentPublishRequest.m
//  Pica
//
//  Created by Fancy on 2021/6/4.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCCommentPublishRequest.h"
#import "PCComment.h"
 
@implementation PCCommentPublishRequest

- (instancetype)initWithGameId:(NSString *)gameId {
    if (self = [super init]) {
        _gameId = [gameId copy];
    }
    return self;
}

- (instancetype)initWithCommentId:(NSString *)commentId {
    if (self = [super init]) {
        _commentId = [commentId copy];
    }
    return self;
}

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
        !success ? : success([PCComment commentWithContent:self.content isChild:(self.commentId != nil)]);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    if (self.comicId) {
        return [NSString stringWithFormat:PC_API_COMICS_COMMENTS, self.comicId];
    } else if (self.commentId) {
        return [NSString stringWithFormat:PC_API_COMMENTS_CHILD_REPLY, self.commentId];
    } else if (self.gameId) {
        return [NSString stringWithFormat:PC_API_GAME_COMMENTS, self.gameId];
    } else {
        return @"";
    }
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"POST" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (id)requestArgument {
    if (self.content.length) {
        return @{@"content" : self.content};
    } else {
        return @{@"content" : @""};
    }
}

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (BOOL)ignoreCache {
    return YES;
}

@end
