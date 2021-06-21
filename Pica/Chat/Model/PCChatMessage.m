//
//  PCChatMessage.m
//  Pica
//
//  Created by Fancy on 2021/6/11.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatMessage.h"
#import "PCVendorHeader.h"
#import "PCUser.h"
#import "NSData+PCAdd.h"
#import <AVFoundation/AVFoundation.h>

@interface PCChatMessage () <AVAudioPlayerDelegate>

@end

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

- (NSData *)audioData {
    if (!_audioData) {
        if (self.audio) {
            _audioData = [[NSData alloc] initWithBase64EncodedString:self.audio options:NSDataBase64DecodingIgnoreUnknownCharacters];
        }
    }
    return _audioData;
}

- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        if (self.audioData) {
            _audioPlayer = [[AVAudioPlayer alloc] initWithData:self.audioData error:nil];
            [_audioPlayer prepareToPlay];
            _audioPlayer.delegate = self;
        }
    }
    return _audioPlayer;
}

- (void)playVoiceMessage {
    if (self.isPlaying) {
        return;
    }
    self.isPlaying = YES;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.audioPlayer play];
}

- (void)pauseVoiceMessage {
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
    }
    self.isPlaying = NO;
}

- (void)stopVoiceMessage {
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
    }
    self.isPlaying = NO;
}

+ (PCChatMessage *)textMessageDataWithText:(NSString *)text
                              replyMessage:(PCChatMessage *)replyMessage
                                        at:(NSString *)at {
    PCUser *myself = [PCUser localUser];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[myself yy_modelToJSONObject]];
    info[@"avatar"] = myself.avatar.imageURL;
    info[@"audio"] = @"";
    info[@"block_user_id"] = @"";
    info[@"platform"] = @"Pica_iOS";
    info[@"reply_name"] = replyMessage ? replyMessage.name : @"";
    info[@"reply"] = replyMessage ? replyMessage.message : @"";
    info[@"at"] = at ? [NSString stringWithFormat:@"嗶咔_%@", at] : @"";
    info[@"message"] = at ? [text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@ ", at] withString:@""] : text;
    info[@"image"] = @"";
    
    NSString *messageData = [NSString stringWithFormat:@"42%@", [@[@"send_message", info] yy_modelToJSONString]];

    PCChatMessage *message = [PCChatMessage yy_modelWithJSON:info];
    message.messageData = messageData;
    message.time = [NSDate date];
    message.user_id = myself.userId;
    
    return message;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    !self.playStateBlock ? : self.playStateBlock(isPlaying);
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.isPlaying = NO;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    self.isPlaying = NO;
    [QMUITips showError:error.domain];
}

+ (PCChatMessage *)imageMessageDataWithData:(NSData *)data {
    PCUser *myself = [PCUser localUser];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[myself yy_modelToJSONObject]];
    info[@"avatar"] = myself.avatar.imageURL;
    info[@"audio"] = @"";
    info[@"block_user_id"] = @"";
    info[@"platform"] = @"Pica_iOS";
    info[@"reply_name"] = @"";
    info[@"reply"] = @"";
    info[@"at"] = @"";
    info[@"message"] = @"";
    
    SDImageFormat format = [NSData sd_imageFormatForImageData:data];
    NSString *base64String = nil;
    NSString *formatString = nil;
    UIImage *image = nil;
    if (format == SDImageFormatGIF) {
        base64String = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        formatString = @"gif";
        image = [SDAnimatedImage imageWithData:data];
    } else {
        UIImage *originalImage = [UIImage imageWithData:data];
        UIImage *resizedImage = [originalImage qmui_imageResizedInLimitedSize:CGSizeMake(1500, 1500)];
        
        base64String = [UIImageJPEGRepresentation(resizedImage, 1) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        formatString = @"jpeg";
        image = resizedImage;
    }
     
    info[@"image"] = [NSString stringWithFormat:@"data:image/%@;base64,%@", formatString, base64String];
    
    NSString *messageData = [NSString stringWithFormat:@"42%@", [@[@"send_image", info] yy_modelToJSONString]];

    PCChatMessage *message = [PCChatMessage yy_modelWithJSON:info];
    message.messageType = PCChatMessageTypeImage;
    message.messageData = messageData;
    message.time = [NSDate date];
    message.user_id = myself.userId;
    message.picture = image;
    
    return message;
}

+ (PCChatMessage *)voiceMessageDataWithData:(NSData *)data {
    PCUser *myself = [PCUser localUser];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[myself yy_modelToJSONObject]];
    info[@"avatar"] = myself.avatar.imageURL;
    info[@"image"] = @"";
    info[@"block_user_id"] = @"";
    info[@"platform"] = @"Pica_iOS";
    info[@"reply_name"] = @"";
    info[@"reply"] = @"";
    info[@"at"] = @"";
    info[@"message"] = @"";
    info[@"audio"] = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSString *messageData = [NSString stringWithFormat:@"42%@", [@[@"send_audio", info] yy_modelToJSONString]];

    PCChatMessage *message = [PCChatMessage yy_modelWithJSON:info];
    message.messageType = PCChatMessageTypeAudio;
    message.messageData = messageData;
    message.time = [NSDate date];
    message.user_id = myself.userId;
    message.audioData = data;
    
    return message;
}

@end
