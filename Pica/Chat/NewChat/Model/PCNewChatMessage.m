//
//  PCNewChatMessage.m
//  Pica
//
//  Created by Fancy on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatMessage.h"
 
@implementation PCNewChatMessage

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"messageId" : @"id",
            @"replyImage" : @"data.reply.image",
            @"replyMessage" : @"data.reply.data.message",
            @"replyMessageId" : @"data.reply.id",
            @"replyMessageType" : @"data.reply.type",
            @"replyUserId" : @"data.reply.userId",
            @"replyUserName" : @"data.reply.data.name",
            @"date" : @"data.message.date",
            @"message" : @"data.message",
            @"caption" : @"data.caption",
            @"medias" : @"data.medias",
            @"userMentions" : @"data.userMentions",
            @"profile" : @"data.profile",
            @"extra" : @"data.extra",
            };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"userMentions" : @"PCUser"};
}
 
- (PCNewChatMessageType)messageType {
    if ([self.type isEqualToString:@"TEXT_MESSAGE"]) {
        return PCNewChatMessageTypeText;
    } else if ([self.type isEqualToString:@"IMAGE_MESSAGE"]) {
        return PCNewChatMessageTypeImage;
    } else {
        return PCNewChatMessageTypeUnknow;
    }
}

@end
