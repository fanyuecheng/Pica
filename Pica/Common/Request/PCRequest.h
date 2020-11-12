//
//  PCRequest.h
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

NS_ASSUME_NONNULL_BEGIN

#define PC_AUTHORIZATION_TOKEN @"PC_AUTHORIZATION_TOKEN"
#define PC_ERROR_DATA          @"PC_ERROR_DATA"

@interface PCRequest : YTKRequest

+ (NSDictionary *)headerWithUrl:(NSString *)url
                         method:(NSString *)method
                           time:(NSDate *)time;


- (void)sendRequest:(nullable void (^)(id response))success
            failure:(nullable void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
