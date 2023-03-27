//
//  PCNewChatLoginRequest.m
//  Pica
//
//  Created by 米画师 on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatLoginRequest.h"

@implementation PCNewChatLoginRequest

- (instancetype)initWithAccount:(NSString *)account
                       password:(NSString *)password {
    if (self = [super init]) {
        self.email = [account copy];
        self.password = [password copy];
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        [kPCUserDefaults setObject:request.responseJSONObject[@"token"] forKey:PC_NEW_CHAT_AUTHORIZATION_TOKEN];
        [kPCUserDefaults synchronize];
        !success ? : success(nil);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return PC_API_NEW_CHAT_SIGNIN;
}

- (id)requestArgument {
    return @{@"email" : self.email.lowercaseString,
             @"password" : self.password};
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

@end
