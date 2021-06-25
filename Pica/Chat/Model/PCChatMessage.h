//
//  PCChatMessage.h
//  Pica
//
//  Created by Fancy on 2021/6/11.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 {
         "at": "",
         "audio": "",
         "avatar": "https://storage.wikawika.xyz/static/2a5d5c50-24ec-4c2d-bc0c-123bcfb8b1cf.jpg",
         "block_user_id": "",
         "character": "https://pica-pica.wikawika.xyz/special/frame-427.png?g=2",
         "event_colors": [
             "#E89005",
             "#EC7505",
             "#D84A05",
             "#F42B03",
             "#E70E02",
             "#F42B03",
             "#D84A05",
             "#EC7505"
         ],
         "gender": "m",
         "image": "",
         "level": 4,
         "message": "只能看猴了😎",
         "name": "吟声呼吸",
         "platform": "android",
         "reply": "我不也是",
         "reply_name": "小潜艇◈",
         "title": "超电磁炮⚡",
         "type": 3,
         "unique_id": "",
         "user_id": "5ef5dbc1bce71f331bd55842",
         "verified": false
     }
 */

typedef NS_ENUM(NSUInteger, PCChatMessageType) {
    PCChatMessageTypeDefault,
    PCChatMessageTypeConnectionCount,
    PCChatMessageTypeAd,
    PCChatMessageTypeAudio,
    PCChatMessageTypeImage,
    PCChatMessageTypeNotification
};

@class UIImage, AVAudioPlayer, PCUser;
@interface PCChatMessage : NSObject

@property (nonatomic, copy) NSString *at;
@property (nonatomic, copy) NSString *audio;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *block_user_id;
@property (nonatomic, copy) NSString *character;
@property (nonatomic, copy) NSArray <NSString *> *event_colors;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *reply;
@property (nonatomic, copy) NSString *reply_name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *unique_id;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) BOOL verified;
@property (nonatomic, assign) NSInteger level;
 
//custom
@property (nonatomic, strong) PCUser   *user;
@property (nonatomic, assign) PCChatMessageType messageType;
@property (nonatomic, assign) NSInteger connections;
@property (nonatomic, strong) NSDate   *time;
@property (nonatomic, strong) UIImage  *picture;
@property (nonatomic, copy)   NSString *messageData;
@property (nonatomic, strong) NSData   *audioData;
@property (nonatomic, assign) BOOL     isPlaying;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, copy)   void (^playStateBlock)(BOOL isPlaying);

- (void)playVoiceMessage;
- (void)pauseVoiceMessage;
- (void)stopVoiceMessage;

+ (PCChatMessage *)messageWithSocketMessage:(NSString *)socketMessage;

+ (PCChatMessage *)textMessageDataWithText:(NSString *)text
                              replyMessage:(PCChatMessage *)replyMessage
                                        at:(NSString *)at;

+ (PCChatMessage *)imageMessageDataWithData:(NSData *)data;
+ (PCChatMessage *)voiceMessageDataWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
