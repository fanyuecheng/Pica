//
//  PCChatManager.h
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PCSocket.h"

NS_ASSUME_NONNULL_BEGIN
 
@class PCChatMessage, PCUser;
@interface PCChatManager : NSObject
 
@property (nonatomic, strong, readonly) PCSocket *socket;

@property (nonatomic, copy) void (^stateBlock)(NSString *state);
@property (nonatomic, copy) void (^messageBlock)(PCChatMessage *message);

- (instancetype)initWithURL:(NSString *)url;

- (void)connect;
- (void)disconnect;
- (void)sendData:(id)data;
- (PCChatMessage *)sendText:(NSString *)text
               replyMessage:(nullable PCChatMessage *)replyMessage
                         at:(nullable PCUser *)at;
- (PCChatMessage *)sendImage:(NSData *)image;
- (PCChatMessage *)sendAudio:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
