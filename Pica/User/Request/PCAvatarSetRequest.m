//
//  PCAvatarSetRequest.m
//  Pica
//
//  Created by YueCheng on 2021/5/27.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCAvatarSetRequest.h"
#import <QMUIKit/QMUIKit.h>

@implementation PCAvatarSetRequest

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
    return PC_API_USERS_AVATAR;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"PUT" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPUT;
}

- (id)requestArgument {
    if (self.avatar) {
        NSString *imageBase64 = [UIImagePNGRepresentation(self.avatar) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        NSString *avatar = [NSString stringWithFormat:@"data:image/png;base64,%@", imageBase64];
        return @{@"avatar" : avatar};
    } else {
        return @{};
    }
}

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (BOOL)ignoreCache {
    return YES;
}

#pragma mark - Set
- (void)setAvatar:(UIImage *)avatar {
    _avatar = [avatar qmui_imageResizedInLimitedSize:CGSizeMake(200, 200)];
}

@end
