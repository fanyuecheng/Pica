//
//  PCSocket.h
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>

NS_ASSUME_NONNULL_BEGIN

/// Websocket连接中的通知
extern NSString * const kWebSocketConnectingNotification;
/// Websocket连接成功的通知
extern NSString * const kWebSocketDidOpenNotification;
/// Websocket连接收到新消息的通知
extern NSString * const kWebSocketDidReceiveMessageNotification;
/// Websocket连接失败的通知
extern NSString * const kWebSocketFailWithErrorNotification;
/// Websocket连接已关闭的通知
extern NSString * const kWebSocketDidCloseNotification;
 
@interface PCSocket : NSObject
+ (instancetype)sharedInstance;
/** 获取连接状态 */
@property (nonatomic, assign, readonly) SRReadyState socketReadyState;
@property (nonatomic, assign) BOOL avoidPing;

/** 开始连接 */
- (void)openSocketWithURL:(NSString *)url;
- (void)openSocket;
- (void)reconnect;

/** 关闭连接 */
- (void)closeSocket;

/** 发送数据 */
- (void)sendData:(id)data;

@end

NS_ASSUME_NONNULL_END
