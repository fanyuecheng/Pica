//
//  PCNewChatRecordRequest.m
//  Pica
//
//  Created by 米画师 on 2023/4/12.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatRecordRequest.h"
#import "PCNewChatMessage.h"
#import "PCVendorHeader.h"
#import "PCDefineHeader.h"

@implementation PCNewChatRecordRequest

- (instancetype)initWithRoomId:(NSString *)roomId
                     messageId:(NSString *)messageId {
    if (self = [super init]) {
        self.roomId = [roomId copy];
        self.messageId = [messageId copy];
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSArray *messages = [NSArray yy_modelArrayWithClass:PCNewChatMessage.class json:request.responseJSONObject[@"messages"]];
        !success ? : success(messages);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return PC_API_NEW_CHAT_RECORD;
}
 
- (id)requestArgument {
    return @{@"roomId" : self.roomId,
             @"messageId" : self.messageId};
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    NSMutableDictionary *header = [super requestHeaderFieldValueDictionary].mutableCopy;
    header[@"authorization"] = [NSString stringWithFormat:@"Bearer %@", [kPCUserDefaults stringForKey:PC_NEW_CHAT_AUTHORIZATION_TOKEN]];
    return header;
}

@end
