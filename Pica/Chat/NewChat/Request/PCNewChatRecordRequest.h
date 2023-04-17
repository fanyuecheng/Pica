//
//  PCNewChatRecordRequest.h
//  Pica
//
//  Created by 米画师 on 2023/4/12.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCNewChatRecordRequest : PCNewChatBaseRequest

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *messageId;

- (instancetype)initWithRoomId:(NSString *)roomId
                     messageId:(NSString *)messageId;

@end

NS_ASSUME_NONNULL_END
