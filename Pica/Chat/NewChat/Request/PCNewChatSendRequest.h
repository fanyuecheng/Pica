//
//  PCNewChatSendRequest.h
//  Pica
//
//  Created by Fancy on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatBaseRequest.h"
#import "PCUser.h"
#import "PCNewChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCNewChatSendRequest : PCNewChatBaseRequest

@property (nonatomic, copy)   NSString *roomId;
@property (nonatomic, copy)   NSString *message;
@property (nonatomic, strong) NSData   *image;
@property (nonatomic, copy)   NSArray <PCUser *>*userMentions;
@property (nonatomic, strong) PCNewChatMessage *replyMessage;

@end

NS_ASSUME_NONNULL_END
