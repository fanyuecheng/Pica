//
//  PCNewChatTextMessageCell.h
//  Pica
//
//  Created by 米画师 on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCNewChatTextMessageCell : PCNewChatMessageCell

@property (nonatomic, strong) QMUILabel *replyLabel;
@property (nonatomic, strong) QMUILabel *messageLabel;

@end

NS_ASSUME_NONNULL_END
