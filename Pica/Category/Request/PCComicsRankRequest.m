//
//  PCComicsRankRequest.m
//  Pica
//
//  Created by 米画师 on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCComicsRankRequest.h"
#import <YYModel/YYModel.h>
#import "PCComics.h"

@implementation PCComicsRankRequest

- (instancetype)initWithType:(PCComicsRankType)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSArray *list = [NSArray yy_modelArrayWithClass:[PCComics class] json:request.responseJSONObject[@"data"][@"comics"]];
        !success ? : success(list);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (NSString *)requestUrl {
    NSMutableString *requestUrl = [NSMutableString stringWithString:PC_API_COMICS_RANK];
    
    switch (self.type) {
        case PCComicsRankTypeH24:
            [requestUrl appendFormat:@"?tt=%@&ct=VC", @"H24"];
            break;
        case PCComicsRankTypeD7:
            [requestUrl appendFormat:@"?tt=%@&ct=VC", @"D7"];
            break;
        default:
            [requestUrl appendFormat:@"?tt=%@&ct=VC", @"D30"];
            break;
    }
    
    return requestUrl;
}

@end
