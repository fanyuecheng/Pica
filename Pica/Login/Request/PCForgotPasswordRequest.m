//
//  PCForgotPasswordRequest.m
//  Pica
//
//  Created by Fancy on 2021/8/3.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCForgotPasswordRequest.h"

@implementation PCForgotPasswordRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        !success ? : success(nil);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return PC_API_AUTH_FORGOT_PSD;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"POST" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (nullable id)requestArgument {
    if (self.email) {
        return @{@"email" : self.email};
    } else {
        return nil;
    }
}

@end
