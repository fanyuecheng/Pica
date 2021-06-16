//
//  PCChatManager.h
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
 
@class PCChatMessage;
@interface PCChatManager : NSObject
 
@property (nonatomic, copy) void (^stateBlock)(NSError * _Nullable error);
@property (nonatomic, copy) void (^messageBlock)(PCChatMessage *message);

- (instancetype)initWithURL:(NSString *)url;

- (void)connect;
- (void)disconnect;
- (void)sendData:(id)data;
- (void)sendText:(NSString *)text;
- (void)sendImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
