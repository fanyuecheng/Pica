//
//  PCRegistRequest.m
//  Pica
//
//  Created by YueCheng on 2021/2/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRegistRequest.h"

@implementation PCRegistRequest

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
    return PC_API_AUTH_REGIST;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"POST" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (nullable id)requestArgument {
    if (self.email &&
        self.password &&
        self.name &&
        self.birthday &&
        self.gender &&
        self.answer1 &&
        self.answer2 &&
        self.answer3 &&
        self.question1 &&
        self.question2 &&
        self.question3) {
        return @{@"email" : self.email,
                 @"password" : self.password,
                 @"name" : self.name,
                 @"birthday" : self.birthday,
                 @"gender" : self.gender,
                 @"answer1" : self.answer1,
                 @"answer2" : self.answer2,
                 @"answer3" : self.answer3,
                 @"question1" : self.question1,
                 @"question2" : self.question2,
                 @"question3" : self.question3};
    } else {
        return nil;
    }
}
 

@end
