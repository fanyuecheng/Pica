//
//  PCNewChatMessageCell.h
//  Pica
//
//  Created by Fancy on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCTableViewCell.h"
#import "PCNewChatMessage.h"
#import "PCNewChatMessageBubbleView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCNewChatMessageCell : PCTableViewCell

@property (nonatomic, strong) PCNewChatMessage *message;

@property (nonatomic, strong) UIImageView      *avatarView;
@property (nonatomic, strong) UIImageView      *characterView;
@property (nonatomic, strong) QMUILabel        *levelLabel;
@property (nonatomic, strong) QMUILabel        *titleLabel;
@property (nonatomic, strong) QMUILabel        *nameLabel;
@property (nonatomic, strong) QMUILabel        *timeLabel;
@property (nonatomic, strong) UIControl        *messageContentView;
@property (nonatomic, strong) PCNewChatMessageBubbleView *messageBubbleView;

@property (nonatomic, copy)   void (^atBlock)(PCNewChatMessage *message); 

- (BOOL)messageOwnerIsMyself;

@end

NS_ASSUME_NONNULL_END
