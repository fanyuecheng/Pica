//
//  PCRequest.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"
#import <QMUIKit/QMUIKit.h>
#import <YYModel/YYModel.h>
#import "NSString+PCAdd.h"
#import "AppDelegate.h"

#define PC_API_KEY_IOS       @"2587EFC6F859B4E3A1D8B6D33B272"
#define PC_API_KEY_ANDROID   @"C69BAF41DA5ABD1FFEDC6D2FEA56B"
#define PC_API_KEY_SECRET_ANDROID    @"~d}$Q7$eIni=V)9\\RK/P.RM4;9[7|@/CA}b~OW!3?EV`:<>M7pddUBL5n|0/*Cn"
#define PC_API_KEY_SECRET_IOS    @"????"

#define PC_VERSION_IOS            @"2.1.2.5"
#define PC_VERSION_ANDROID        @"2.2.1.3.3.4"
#define PC_BUILD_VERSION_IOS      @"34"
#define PC_BUILD_VERSION_ANDROID  @"45"
#define PC_PLATFORM_IOS           @"ios"
#define PC_PLATFORM_ANDROID       @"android"
 
//cb69a7aa-b9a8-3320-8cf1-74347e9ee970
//cb69a7aa-b9a8-3320-8cf1-74347e9ee979
//1A8BF3E5-0358-42D5-9814-7C79A24B6ACC
#define PC_APP_UUID               @"cb69a7aa-b9a8-3320-8cf1-74347e9ee970"
//original","low","medium","high"
#define PC_APP_IMAGE_QUALITY      @"original"
#define PC_USER_AGENT_IOS         @"sora/1 CFNetwork/1128.0.1 Darwin/19.6.0"
#define PC_USER_AGENT_ANDROID     @"okhttp/3.8.1"

@implementation PCRequest
  
+ (NSDictionary *)headerWithUrl:(NSString *)url
                         method:(NSString *)method
                           time:(NSDate *)time {
    NSString *timeInterval = [NSString stringWithFormat:@"%.f", time.timeIntervalSince1970];
    NSString *uuid = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""].lowercaseString;
    NSString *channel = [kPCUserDefaults stringForKey:PC_API_CHANNEL];
    if (channel.length == 0) {
        channel = @"1";
        [kPCUserDefaults setObject:@"1" forKey:PC_API_CHANNEL];
    }
    
    NSMutableDictionary *header = @{
                            @"api-key"           : PC_API_KEY_ANDROID,
                            @"accept"            : @"application/vnd.picacomic.com.v1+json",
                            @"app-channel"       : PC_API_CHANNEL,
                            @"time"              : timeInterval,
                            @"nonce"             : uuid,
                            @"signature"         : @"",
                            @"app-version"       : PC_VERSION_ANDROID,
                            @"app-uuid"          : PC_APP_UUID,
                            @"app-platform"      : PC_PLATFORM_ANDROID,
                            @"app-build-version" : PC_BUILD_VERSION_ANDROID,
                            @"Content-Type"      : @"application/json; charset=UTF-8",
                            @"User-Agent"        : PC_USER_AGENT_ANDROID,
                            @"image-quality"     : PC_APP_IMAGE_QUALITY,
                            @"accept-encoding"   : @"gzip"
    }.mutableCopy;
     
    NSString *raw = [NSString stringWithFormat:@"%@%@%@%@%@", [url stringByReplacingOccurrencesOfString:PC_API_HOST_ANDROID withString:@""], timeInterval, uuid, method, PC_API_KEY_ANDROID].lowercaseString;
    header[@"signature"] = [raw pc_hmacSHA256StringWithKey:PC_API_KEY_SECRET_ANDROID];
     
    NSString *token = [kPCUserDefaults stringForKey:PC_AUTHORIZATION_TOKEN];
    if (token.length) {
        header[@"authorization"] = token;
    }
    
    return header;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [self addAccessory];
}

- (void)addAccessory {
    [self.requestAccessories removeAllObjects];
    YTKRequestEventAccessory *accessory = [[YTKRequestEventAccessory alloc] init];
    accessory.willStartBlock = ^(PCRequest *_Nonnull request) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
    };
    
    accessory.willStopBlock = ^(PCRequest *_Nonnull request) {
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
    return PC_API_HOST_ANDROID;
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

@end
