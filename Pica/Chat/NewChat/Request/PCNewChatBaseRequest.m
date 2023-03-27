//
//  PCNewChatBaseRequest.m
//  Pica
//
//  Created by Fancy on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatBaseRequest.h"
#import <QMUIKit/QMUIKit.h>
#import <YYModel/YYModel.h>
#import "NSString+PCAdd.h"
#import "AppDelegate.h"

@implementation PCNewChatBaseRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [self addAccessory];
}

- (void)addAccessory {
    [self.requestAccessories removeAllObjects];
    YTKRequestEventAccessory *accessory = [[YTKRequestEventAccessory alloc] init];
    accessory.willStartBlock = ^(PCNewChatBaseRequest *_Nonnull request) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
    };
    
    accessory.willStopBlock = ^(PCNewChatBaseRequest *_Nonnull request) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (request.error) {
                NSDictionary *response = request.responseJSONObject;
                [request.error qmui_bindObject:response forKey:PC_ERROR_DATA];
                [QMUITips showError:[NSString stringWithFormat:@"error:%@\nmessage:%@\ndetail:%@", response[@"error"], response[@"message"], response[@"detail"]] inView:DefaultTipsParentView];
                if ([response[@"error"] isEqualToString:@"1005"] &&
                    [response[@"message"] isEqualToString:@"unauthorized"] &&
                    [response[@"code"] integerValue] == 401) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [(AppDelegate *)[UIApplication sharedApplication].delegate setRootViewControllerToLogin];
                    });
                }
#if defined(DEBUG)
                NSLog(@"\n============ PCRequest Info] ============\nrequest method: %@  from cache: %@\nrequest url: %@\nrequest parameters: \n%@\nrequest error:\n%@\nresponse:\n%@\n%@\n==========================================\n", self.methodString, self.isDataFromCache ? @"YES" : @"NO", self.requestUrl, self.requestArgument, self.error, self.response, self.responseObject);
#endif
            }
        });
    };

    [self addAccessory:accessory];
}

- (void)requestCompletePreprocessor {
    [super requestCompletePreprocessor];
#if defined(DEBUG)
    NSLog(@"\n============ [PCRequest Info] ============\nrequest method: %@  from cache: %@\nrequest url: %@\nrequest parameters: \n%@\nrequest response:\n%@\n%@\n==========================================\n", self.methodString, self.isDataFromCache ? @"YES" : @"NO", self.requestUrl, self.requestArgument, self.response, self.responseJSONObject);
#endif
    if (!self.error && [kPCUserDefaults boolForKey:PC_DATA_TO_SIMPLIFIED_CHINESE]) {
        NSString *simplifiedChinese = [self.responseString pc_simplifiedChinese];
        NSDictionary *object = [NSJSONSerialization JSONObjectWithData:[simplifiedChinese dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        [self setValue:simplifiedChinese forKey:@"responseString"];
        [self setValue:object forKey:@"responseObject"];
        [self setValue:object forKey:@"responseJSONObject"];
    }
}

- (NSString *)methodString {
    NSString *methodString = nil;
    switch (self.requestMethod) {
        case YTKRequestMethodGET:
            methodString = @"GET";
            break;
        case YTKRequestMethodPOST:
            methodString = @"POST";
            break;
        case YTKRequestMethodHEAD:
            methodString = @"HEAD";
            break;
        case YTKRequestMethodPUT:
            methodString = @"PUT";
            break;
        case YTKRequestMethodDELETE:
            methodString = @"DELETE";
            break;
        case YTKRequestMethodPATCH:
            methodString = @"PATCH";
            break;
        default:
            methodString = @"UNKNOW";
            break;
    }
    return methodString;
}

- (NSString *)baseUrl {
    return PC_API_NEW_CHAT_HOST;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return @{@"user-agent" : @"Dart/2.19 (dart:io)",
             @"accept-encoding" : @"gzip",
             @"api-version" : @"1.0.2",
             @"content-type" : @"application/json; charset=UTF-8"};
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (BOOL)ignoreCache {
    return YES;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 30;
}

@end
