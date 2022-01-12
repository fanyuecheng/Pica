//
//  PCRandomRequest.m
//  Pica
//
//  Created by YueCheng on 2021/5/27.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRandomRequest.h"
#import <YYModel/YYModel.h>
#import "PCComic.h"

@implementation PCRandomRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSArray *comics = request.responseJSONObject[@"data"][@"comics"];
        NSArray <PCComic *> *comicArray = [NSArray yy_modelArrayWithClass:[PCComic class] json:comics];
        
        PCComicList *list = [[PCComicList alloc] init];
        list.total = comicArray.count;
        list.page = 1;
        list.pages = 1;
        list.docs = comicArray;
        
        !success ? : success(list);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return PC_API_COMICS_RANDOOM;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (BOOL)ignoreCache {
    return YES;
}

@end
