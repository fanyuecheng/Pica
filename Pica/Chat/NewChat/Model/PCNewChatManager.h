//
//  PCNewChatManager.h
//  Pica
//
//  Created by Fancy on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCSocket.h"
#import "PCNewChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCNewChatManager : NSObject

@property (nonatomic, strong, readonly) PCSocket *socket;

@property (nonatomic, copy) void (^stateBlock)(NSString *state);
@property (nonatomic, copy) void (^messageBlock)(PCNewChatMessage *message);

- (instancetype)initWithRoomId:(NSString *)roomId;

- (void)connect;
- (void)disconnect;
 
- (void)sendMessage:(NSString *)message
              image:(nullable NSData *)image
             replay:(nullable PCNewChatMessage *)replay
            mention:(nullable NSArray <PCUser *> *)mention
           finished:(void (^)(PCNewChatMessage *message, NSError *error))finished;
@end

NS_ASSUME_NONNULL_END
