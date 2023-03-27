//
//  PCNewChatRoomRequest.m
//  Pica
//
//  Created by 米画师 on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatRoomRequest.h"
#import <YYModel/YYModel.h>

@implementation PCNewChatRoomRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSArray *rooms = [NSArray yy_modelArrayWithClass:PCNewChatRoom.class json:request.responseJSONObject[@"rooms"]]; 
        !success ? : success(rooms);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return PC_API_NEW_CHAT_ROOM;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    NSMutableDictionary *header = [super requestHeaderFieldValueDictionary].mutableCopy;
    header[@"authorization"] = [NSString stringWithFormat:@"Bearer %@", [kPCUserDefaults stringForKey:PC_NEW_CHAT_AUTHORIZATION_TOKEN]];
    return header;
}

@end
