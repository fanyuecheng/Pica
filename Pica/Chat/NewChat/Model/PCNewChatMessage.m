//
//  PCNewChatMessage.m
//  Pica
//
//  Created by 米画师 on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatMessage.h"
 
@implementation PCNewChatMessage

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"messageId" : @"id",
            @"replyImage" : @"data.reply.image",
            @"replyMessage" : @"data.reply.message",
            @"replyMessageId" : @"data.reply.id",
            @"replyMessageType" : @"data.reply.type",
            @"replyUserName" : @"data.reply.name",
            @"date" : @"data.message.date",
            @"message" : @"data.message.message",
            @"caption" : @"data.message.caption",
            @"medias" : @"data.message.medias",
            @"userMentions" : @"data.userMentions",
            @"profile" : @"data.profile", 
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
