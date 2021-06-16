//
//  PCChatListRequest.m
//  Pica
//
//  Created by Fancy on 2021/6/11.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatListRequest.h"
#import "PCChatList.h"
#import <YYModel/YYModel.h>

@implementation PCChatListRequest
 
- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSArray *list = [NSArray yy_modelArrayWithClass:[PCChatList class] json:request.responseJSONObject[@"data"][@"chatList"]];
        !success ? : success(list);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return PC_API_CHAT;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 60;
}

- (BOOL)ignoreCache {
    return NO;
}

@end
