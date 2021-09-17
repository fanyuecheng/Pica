//
//  PCSocket.m
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCSocket.h"
#import "PCVendorHeader.h"
#import "PCDefineHeader.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

NSString * const kWebSocketConnectingNotification = @"kWebSocketConnectingNotification";
NSString * const kWebSocketDidOpenNotification = @"kWebSocketDidOpenNotification";
NSString * const kWebSocketDidReceiveMessageNotification = @"kWebSocketDidReceiveMessageNotification";
NSString * const kWebSocketFailWithErrorNotification = @"kWebSocketFailWithErrorNotification";
NSString * const kWebSocketDidCloseNotification = @"kWebSocketDidCloseNotification";

@interface PCSocket () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket    *socket;
@property (nonatomic, copy)   NSString       *url;

@property (nonatomic, assign) NSTimeInterval pingDuration;
@property (nonatomic, strong) NSTimer        *heartbeatTimer;
@property (nonatomic, assign) NSUInteger     reconnectCount;
@property (nonatomic, assign) BOOL           autoReconnect;
@property (nonatomic, assign) BOOL           isBackground;

@end

@implementation PCSocket

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PCSocket *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        self.pingDuration = 15;
        self.autoReconnect = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification
- (void)appWillEnterForeground:(NSNotification *)notification {
    self.isBackground = NO;
    [self openSocket];
}

- (void)appDidEnterBackground:(NSNotification *)notification {
    self.isBackground = YES;
    [self closeSocket];
}

- (void)reachabilityDidChange:(NSNotification *)notification {
    /*
    NSDictionary *userInfo = @{ AFNetworkingReachabilityNotificationStatusItem: @(status) };
     */
    AFNetworkReachabilityStatus status = [notification.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    //WWAN || Wifi && !self.socket
    if ((status == 1 || status == 2) && !self.socket) {
        [self openSocket];
    }
}

#pragma mark - Public Method
- (void)openSocket {
    if (self.url) {
        [self openSocketWithURL:self.url];
    }
}

- (void)openSocketWithURL:(NSString *)url {
    if (self.socket) {
        return;
    }
    
    if (!url) {
        return;
    }
    
    self.url = url;
    self.socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url]];
    self.socket.delegate = self;
    [self.socket open];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketConnectingNotification object:nil];
}

- (void)closeSocket {
    if (self.socket) {
        [self.socket close];
        self.socket = nil;
        [self destoryHeartBeat];
    }
}

- (void)sendData:(id)data {
    @weakify(self)
    dispatch_queue_t queue = dispatch_queue_create("MHS_SOCKET_QUEUE", NULL);
    
    dispatch_async(queue, ^{
        @strongify(self)
        if (self.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法
            if (self.socket.readyState == SR_OPEN) {
                if ([data isKindOfClass:[NSString class]]) {
                    [self.socket sendString:data error:nil];
                } else if ([data isKindOfClass:[NSData class]]) {
                    [self.socket sendData:data error:nil];
                }
                
                QMUILogInfo(@"SOCKET_发送data", @"%@", data);
            } else if (self.socket.readyState == SR_CONNECTING) {
                [self reconnect];
            } else if (self.socket.readyState == SR_CLOSING ||
                       self.socket.readyState == SR_CLOSED) {
                [self reconnect];
            }
        } else {
            QMUILogInfo(@"SOCKET_没网络，发送失败，一旦断网 socket 会被我设置 nil 的", @"");
        }
    });
}

#pragma mark - Private Mothode
//重连机制
- (void)reconnect {
    [self closeSocket];
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (self.reconnectCount > 64) {
        return;
    }
    
    if (!self.autoReconnect) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reconnectCount * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openSocketWithURL:self.url];
    });
    
    //重连时间2的指数级增长
    if (self.reconnectCount == 0) {
        self.reconnectCount = 2;
    } else {
        self.reconnectCount *= 2;
    }
}


//取消心跳
- (void)destoryHeartBeat {
    if (self.heartbeatTimer) {
        if ([self.heartbeatTimer respondsToSelector:@selector(isValid)]) {
            if ([self.heartbeatTimer isValid]) {
                [self.heartbeatTimer invalidate];
                self.heartbeatTimer = nil;
            }
        }
    }
}

//初始化心跳
- (void)initHeartBeat {
    [self destoryHeartBeat];
    //心跳设置为3分钟，NAT超时一般为5分钟
    self.heartbeatTimer = [NSTimer timerWithTimeInterval:self.pingDuration target:self selector:@selector(sentHeart) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.heartbeatTimer forMode:NSRunLoopCommonModes];
}

- (void)sentHeart {
    [self ping];
}
 
- (void)ping {
    //[self.socket sendPing:<#(NSData *)#>] 必须为字符串 data 会断开
    [self sendData:@"2"];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    self.reconnectCount = 0;
    [self initHeartBeat];
 
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidOpenNotification object:nil];
    QMUILogInfo(@"SOCKET_连接成功", @"%@", webSocket);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketFailWithErrorNotification object:error];
    //连接失败就重连
    [self reconnect];
    QMUILogInfo(@"SOCKET_连接失败", @"%@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidCloseNotification object:@(code)];
    [self closeSocket];
    QMUILogInfo(@"SOCKET_连接关闭", @"code:%ld reason:%@, wasClean:%d", (long)code, reason, wasClean);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    QMUILogInfo(@"SOCKET_收到心跳", @"%@, %@", reply, pongPayload);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidReceiveMessageNotification object:message];
    QMUILogInfo(@"SOCKET_收到message", @"%@", message);
}

#pragma mark - Get
- (SRReadyState)socketReadyState {
    return self.socket.readyState;
}
 
@end
