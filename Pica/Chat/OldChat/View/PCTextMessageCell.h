//
//  PCTextMessageCell.h
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCTextMessageCell : PCChatMessageCell

@property (nonatomic, strong) QMUILabel *replyLabel;
@property (nonatomic, strong) QMUILabel *messageLabel;

@property (nonatomic, copy)   void (^replayBlock)(PCChatMessage *message);
@property (nonatomic, copy)   void (^privateBlock)(PCChatMessage *message);

@end

NS_ASSUME_NONNULL_END
