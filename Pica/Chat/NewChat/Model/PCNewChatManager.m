//
//  PCNewChatManager.m
//  Pica
//
//  Created by Fancy on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatManager.h"
#import "PCDefineHeader.h"
#import "PCVendorHeader.h"
#import "PCNewChatSendRequest.h"
 
@interface PCNewChatManager ()

@property (nonatomic, copy)   NSString *roomId;
@property (nonatomic, copy)   NSString *url;
@property (nonatomic, strong) PCSocket *socket;

@end

@implementation PCNewChatManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithRoomId:(NSString *)roomId {
    if (self = [super init]) {
        self.roomId = roomId;
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
    self.socket.avoidPing = YES;
    [self.socket openSocketWithURL:self.url];
}

- (void)disconnect {
    [self.socket closeSocket];
}

- (void)sendMessage:(NSString *)message
              image:(NSData *)image
             replay:(PCNewChatMessage *)replay
            mention:(NSArray <PCUser *> *)mention
           finished:(void (^)(PCNewChatMessage *message, NSError *error))finished {
    PCNewChatSendRequest *request = [[PCNewChatSendRequest alloc] init];
    request.message = message;
    request.image = image;
    request.replyMessage = replay;
    request.userMentions = mention;
    request.roomId = self.roomId;
    
    [request sendRequest:^(id response) {
        !finished ? : finished(response, nil);
    } failure:^(NSError *error) {
        !finished ? : finished(nil, error);
    }];
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
    NSString *jsonString = noti.object;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    if ([jsonObject[@"type"] isEqualToString:@"CONNECTED"]) {
        //链接成功
        //{"type":"CONNECTED","data":{"data":"2023-03-27T04:12:42+00:00"}}
        return;
    }
    PCNewChatMessage *message = [PCNewChatMessage yy_modelWithJSON:jsonObject];
    if (message) {
        !self.messageBlock ? : self.messageBlock(message);
    }
}
  

#pragma mark - Set
- (void)setRoomId:(NSString *)roomId {
    _roomId = roomId;
    self.url = [NSString stringWithFormat:@"wss://live-server.bidobido.xyz/?token=%@&room=%@", [kPCUserDefaults stringForKey:PC_NEW_CHAT_AUTHORIZATION_TOKEN], roomId];
}

@end
