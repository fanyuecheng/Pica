//
//  PCNewChatBaseRequest.h
//  Pica
//
//  Created by Fancy on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>
#import "PCLocalKeyHeader.h"

#define PC_API_NEW_CHAT_HOST      @"https://live-server.bidobido.xyz/"
#define PC_API_NEW_CHAT_SIGNIN    @"auth/signin"
#define PC_API_NEW_CHAT_PROFILE   @"user/profile"
#define PC_API_NEW_CHAT_ROOM      @"room/list"
#define PC_API_NEW_CHAT_SEND_TXT  @"room/send-message"
#define PC_API_NEW_CHAT_SEND_IMG  @"room/send-image"

NS_ASSUME_NONNULL_BEGIN

@interface PCNewChatBaseRequest : YTKRequest

- (void)sendRequest:(nullable void (^)(id response))success
            failure:(nullable void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
