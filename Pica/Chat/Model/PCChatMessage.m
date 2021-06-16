//
//  PCChatMessage.m
//  Pica
//
//  Created by Fancy on 2021/6/11.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatMessage.h"
#import "PCVendorHeader.h"

@implementation PCChatMessage

+ (PCChatMessage *)messageWithSocketMessage:(NSString *)socketMessage {
    if ([socketMessage hasPrefix:@"42"]) {
        NSData *jsonData = [[socketMessage stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""] dataUsingEncoding:NSUTF8StringEncoding];
     
        NSError *error = nil;
        NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&error];
        NSString *messageType = jsonObject.firstObject;
        id messageObject = jsonObject.lastObject;
        PCChatMessage *message = [PCChatMessage yy_modelWithJSON:messageObject];
        message.time = [NSDate date];
        message.message = [message.message qmui_trim];
        if ([messageType isEqualToString:@"new_connection"]) {
            message.messageType = PCChatMessageTypeConnectionCount;
        } else if ([messageType isEqualToString:@"broadcast_message"]) {
            message.messageType = PCChatMessageTypeDefault;
        } else if ([messageType isEqualToString:@"broadcast_ads"]) {
            message.messageType = PCChatMessageTypeAd;
        } else if ([messageType isEqualToString:@"broadcast_image"]) {
            message.messageType = PCChatMessageTypeImage;
        } else if ([messageType isEqualToString:@"receive_notification"]) {
            message.messageType = PCChatMessageTypeNotification;
        } else if ([messageType isEqualToString:@"broadcast_audio"]) {
            message.messageType = PCChatMessageTypeAudio;
        }

        return message;
    } else {
        return nil;
    }
}

- (UIImage *)picture {
    if (!_picture) {
        if ([self.image containsString:@";base64,"]) {
            _picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.image]]];
        } else {
            NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:self.image options:NSDataBase64DecodingIgnoreUnknownCharacters];
            _picture = [[SDImageCodersManager sharedManager] decodedImageWithData:decodeData options:nil];
        }
    }
    return _picture;
}

@end
