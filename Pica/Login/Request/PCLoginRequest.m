//
//  PCLoginRequest.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCLoginRequest.h"
#import "PCUser.h"

@implementation PCLoginRequest

- (instancetype)initWithAccount:(NSString *)account
                       password:(NSString *)password {
    if (self = [super init]) {
        self.account = [account copy];
        self.password = [password copy];
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSString *token = request.responseJSONObject[@"data"][@"token"];
        [kPCUserDefaults setObject:token forKey:PC_AUTHORIZATION_TOKEN];
        NSMutableArray *accountArray = [[kPCUserDefaults arrayForKey:PC_LOCAL_ACCOUNT] mutableCopy];
        if (!accountArray) {
            accountArray = [NSMutableArray array];
        }
        if (![accountArray containsObject:self.account]) {
            [accountArray addObject:self.account];
        }
        [kPCUserDefaults setObject:accountArray forKey:PC_LOCAL_ACCOUNT];
        !success ? : success(token);
        [PCUser requsetMyself:nil];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return PC_API_AUTH_SIGN_IN;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"POST" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (nullable id)requestArgument {
    if (self.account && self.password) {
        return @{@"email" : self.account,
                 @"password"  : self.password};
    } else {
        return nil;
    }
}
 
@end
