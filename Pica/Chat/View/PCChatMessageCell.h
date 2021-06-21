//
//  PCChatMessageCell.h
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class PCChatMessage, PCMessageBubbleView;
@interface PCChatMessageCell : PCTableViewCell

@property (nonatomic, strong) PCChatMessage *message;

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *characterView;
@property (nonatomic, strong) QMUILabel   *levelLabel;
@property (nonatomic, strong) QMUILabel   *titleLabel;
@property (nonatomic, strong) QMUILabel   *nameLabel;
@property (nonatomic, strong) QMUILabel   *timeLabel;
@property (nonatomic, strong) UIControl   *messageContentView;
@property (nonatomic, strong) PCMessageBubbleView *messageBubbleView;

- (BOOL)messageOwnerIsMyself;

@end

NS_ASSUME_NONNULL_END
