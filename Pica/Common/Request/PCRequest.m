//
//  PCRequest.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"
#import <QMUIKit/QMUIKit.h>
#import "NSString+PCAdd.h"

//2587EFC6F859B4E3A1D8B6D33B272  ios
#define kApiKey        @"C69BAF41DA5ABD1FFEDC6D2FEA56B"
//~n}$S9$lGts=U)8zfL/R.PM9;4[3|@/CEsl~Kk!7?BYZ:BAa5zkkRBL7r|1/*Cr  ❎
//~d}$Q7$eIni=V)9RK/P.RM4;9[7|@/CA}b~OW!3?EV`:<>M7pddUBL5n|0/*Cn   ❎
//~d}$Q7$eIni=V)9\\RK/P.RM4;9[7|@/CA}b~OW!3?EV`:<>M7pddUBL5n|0/*Cn ✅

#define kSecretKey     @"~d}$Q7$eIni=V)9\\RK/P.RM4;9[7|@/CA}b~OW!3?EV`:<>M7pddUBL5n|0/*Cn"
#define kVersion       @"2.2.1.3.3.4"
#define kBuildVersion  @"45"
#define kVhannel       @"1" // 2 3
//cb69a7aa-b9a8-3320-8cf1-74347e9ee970
//cb69a7aa-b9a8-3320-8cf1-74347e9ee979
#define kAppUUID       @"cb69a7aa-b9a8-3320-8cf1-74347e9ee970"
//original","low","medium","high"

@implementation PCRequest
  
+ (NSDictionary *)headerWithUrl:(NSString *)url
                         method:(NSString *)method
                           time:(NSDate *)time {
    NSString *timeInterval = [NSString stringWithFormat:@"%.f", time.timeIntervalSince1970];
    NSString *uuid = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""].lowercaseString;
    NSMutableDictionary *header = @{
                            @"api-key"           : kApiKey,
                            @"accept"            : @"application/vnd.picacomic.com.v1+json",
                            @"app-channel"       : kVhannel,
                            @"time"              : timeInterval,
                            @"nonce"             : uuid,
                            @"signature"         : @"",
                            @"app-version"       : kVersion,
                            @"app-uuid"          : kAppUUID,
                            @"app-platform"      : @"android",
                            @"app-build-version" : kBuildVersion,
                            @"Content-Type"      : @"application/json; charset=UTF-8",
                            @"User-Agent"        : @"okhttp/3.8.1",
                            @"image-quality"     : @"original",
                            @"accept-encoding"   : @"gzip"
    }.mutableCopy;
     
    NSString *raw = [NSString stringWithFormat:@"%@%@%@%@%@", [url stringByReplacingOccurrencesOfString:@"https://picaapi.picacomic.com/" withString:@""], timeInterval, uuid, method, kApiKey].lowercaseString;
    header[@"signature"] = [raw pc_hmacSHA256StringWithKey:kSecretKey];
     
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:PC_AUTHORIZATION_TOKEN];
    if (token.length) {
        header[@"authorization"] = token;
    }
    
    return header;
}

- (instancetype)init {
    if (self = [super init]) {
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
                    [request.error qmui_bindObject:request.responseJSONObject forKey:PC_ERROR_DATA];
                    [QMUITips showError:request.responseJSONObject[@"message"]];
                }
            });
            
#if defined(DEBUG)
            if (request.error) {
                NSLog(@"\n============ PCRequest Info] ============\nrequest method: %zd\nrequest url: %@\nrequest parameters: \n%@\nrequest error:\n%@\nresponse:\n%@\n==========================================\n", request.requestMethod, request.requestUrl, request.requestArgument, request.error, request.response);
            } else {
                NSLog(@"\n============ [PCRequest Info] ============\nrequest method: %zd\nrequest url: %@\nrequest parameters: \n%@\nrequest response:\n%@\n==========================================\n", request.requestMethod, request.requestUrl, request.requestArgument, request.responseJSONObject);
            }
#endif
        };

        [self addAccessory:accessory];
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
 
}

- (NSString *)baseUrl {
    return PC_API_HOST;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (NSInteger)cacheTimeInSeconds {
    return 3600;
}

- (BOOL)ignoreCache {
    return NO;
}

@end
