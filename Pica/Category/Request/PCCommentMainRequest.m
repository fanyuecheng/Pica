//
//  PCCommentMainRequest.m
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCommentMainRequest.h"
#import <YYModel/YYModel.h>

@interface PCCommentMainRequest ()
 
@end

@implementation PCCommentMainRequest

- (instancetype)initWithObjectId:(NSString *)objectId {
    if (self = [super init]) {
        _objectId = [objectId copy];
        _page = 1;
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCComicComment *comment = [PCComicComment yy_modelWithJSON:request.responseJSONObject[@"data"]];
        
        !success ? : success(comment);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    NSMutableString *requestUrl = self.type == PCCommentTypeComic ? [NSMutableString stringWithFormat:PC_API_COMICS_COMMENTS, self.objectId] : [NSMutableString stringWithFormat:PC_API_GAME_COMMENTS, self.objectId];
    [requestUrl appendFormat:@"?page=%@", @(self.page)];
    return requestUrl;
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
