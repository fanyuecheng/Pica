//
//  PCTestRequest.m
//  Pica
//
//  Created by Fancy on 2021/7/27.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCTestRequest.h"
#import "PCUser.h"
 
@implementation PCTestRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        !success ? : success(request.responseObject);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"users/%@/character", [PCUser localUser].userId];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"PUT" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPUT;
}

- (id)requestArgument {
    return @{@"character" : @"test"};
}

@end
