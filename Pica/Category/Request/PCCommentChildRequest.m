//
//  PCCommentChildRequest.m
//  Pica
//
//  Created by Fancy on 2021/6/4.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCCommentChildRequest.h"
#import <YYModel/YYModel.h>
#import "PCComment.h"

@implementation PCCommentChildRequest

- (instancetype)initWithCommentId:(NSString *)commentId {
    if (self = [super init]) {
        _commentId = [commentId copy];
        _page = 1;
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCComicsComment *comment = [PCComicsComment yy_modelWithJSON:request.responseJSONObject[@"data"]]; 
        [comment.docs enumerateObjectsUsingBlock:^(PCComment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isChild = YES;
        }];
        !success ? : success(comment);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl { 
    return [NSString stringWithFormat:PC_API_COMICS_COMMENTS_CHILD, self.commentId, @(self.page)];
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
