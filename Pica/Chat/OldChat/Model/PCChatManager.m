//
//  PCChatManager.m
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatManager.h"
#import "PCSocket.h"
#import "PCDefineHeader.h"
#import "PCChatMessage.h"
#import "PCUser.h"
#import "PCVendorHeader.h"

@interface PCChatManager ()

@property (nonatomic, copy)   NSString *url;
@property (nonatomic, strong) PCSocket *socket;

@end

@implementation PCChatManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithURL:(NSString *)url {
    if (self = [super init]) {
        self.url = url;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketDidOpenNotification:) name:kWebSocketDidOpenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketDidReceiveMessageNotification:) name:kWebSocketDidReceiveMessageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketFailNotification:) name:kWebSocketFailWithErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketCloseNotification:) name:kWebSocketDidCloseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketConnectingNotification:) name:kWebSocketConnectingNotification object:nil];
    }
    return self;
}

#pragma mark - Public Method
- (void)connect {
    self.socket.avoidPing = NO;
    [self.socket openSocketWithURL:self.url];
}

- (void)disconnect {
    [self.socket closeSocket];
}

- (void)sendData:(id)data {
    [self.socket sendData:data];
}

- (PCChatMessage *)sendText:(NSString *)text
               replyMessage:(PCChatMessage *)replyMessage
                         at:(PCUser *)at {
    if (text) {
        PCChatMessage *message = [PCChatMessage textMessageDataWithText:text replyMessage:replyMessage at:at];
        [self sendData:message.messageData];
        return message;
    } else {
        return nil;
    }
}

- (PCChatMessage *)sendImage:(NSData *)image {
    if (image) {
        PCChatMessage *message = [PCChatMessage imageMessageDataWithData:image];
        [self sendData:message.messageData];
        return message;
    } else {
        return nil;
    }
}

- (PCChatMessage *)sendAudio:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        PCChatMessage *message = [PCChatMessage voiceMessageDataWithData:data];
        [self sendData:message.messageData];
        [kDefaultFileManager removeItemAtPath:path error:nil];
        return message;
    } else {
        return nil;
    }
}

#pragma mark - Private Method
- (void)sendInitData {
    NSDictionary *user = [kPCUserDefaults objectForKey:PC_LOCAL_USER];
    NSString *msg = [NSString stringWithFormat:@"42%@", [@[@"init", user] yy_modelToJSONString]];
    [self sendData:msg];
}

#pragma mark - Get
- (PCSocket *)socket {
    if (!_socket) {
        _socket = [PCSocket sharedInstance];
    }
    return _socket;
}

#pragma mark - Notification
- (void)socketDidOpenNotification:(NSNotification *)noti {
    [self sendInitData];
    !self.stateBlock ? : self.stateBlock(@"open");
}

- (void)socketFailNotification:(NSNotification *)noti {
    !self.stateBlock ? : self.stateBlock(@"error");
}

- (void)socketCloseNotification:(NSNotification *)noti {
    !self.stateBlock ? : self.stateBlock(@"close");
}

- (void)socketConnectingNotification:(NSNotification *)noti {
    !self.stateBlock ? : self.stateBlock(@"connecting");
}

- (void)socketDidReceiveMessageNotification:(NSNotification *)noti {
    id message = noti.object;
    PCChatMessage *msg = [PCChatMessage messageWithSocketMessage:message];
    if (msg) {
        !self.messageBlock ? : self.messageBlock(msg);
    }
}
  
@end
