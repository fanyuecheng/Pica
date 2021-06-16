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
#import <YYModel/YYModel.h>

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
    }
    return self;
}

#pragma mark - Public Method
- (void)connect {
    [self.socket openSocketWithURL:self.url];
}

- (void)disconnect {
    [self.socket closeSocket];
}

- (void)sendData:(id)data {
    [self.socket sendData:data];
}

- (void)sendText:(NSString *)text {
    
}

- (void)sendImage:(UIImage *)image {
    
}

#pragma mark - Private Method
- (void)sendInitData {
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:PC_LOCAL_USER];
    NSString *msg = [NSString stringWithFormat:@"42%@", [@[@"init", user] yy_modelToJSONString]];
    [self sendData:msg];
}

#pragma mark - Get
- (PCSocket *)socket {
    if (!_socket) {
        _socket = [[PCSocket alloc] init];
    }
    return _socket;
}

#pragma mark - Notification
- (void)socketDidOpenNotification:(NSNotification *)noti {
    [self sendInitData];
    !self.stateBlock ? : self.stateBlock(nil);
}

- (void)socketFailNotification:(NSNotification *)noti {
    !self.stateBlock ? : self.stateBlock(noti.object);
}

- (void)socketDidReceiveMessageNotification:(NSNotification *)noti {
    id message = noti.object;
    PCChatMessage *msg = [PCChatMessage messageWithSocketMessage:message];
    if (msg) {
        !self.messageBlock ? : self.messageBlock(msg);
    }
}
  
@end
