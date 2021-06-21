//
//  PCChatMessageCell.m
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatMessageCell.h"
#import "PCVendorHeader.h"
#import "PCCommonUI.h"
#import "PCChatMessage.h"
#import "PCMessageBubbleView.h"
#import "PCUser.h"
#import "UIImageView+PCAdd.h"

@interface PCChatMessageCell ()

@property (nonatomic, strong) PCUser *myself;

@end

@implementation PCChatMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorWhite;
        
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.characterView];
        [self.contentView addSubview:self.levelLabel];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.messageContentView];
        [self.contentView insertSubview:self.messageBubbleView  belowSubview:self.messageContentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
   
    [self.levelLabel sizeToFit];
    [self.titleLabel sizeToFit];
    [self.nameLabel sizeToFit];
    [self.timeLabel sizeToFit];
    /*
        10
     15-40-15-level-5-title
             5
             -name
             -content maxw = screenw-70-10
     */
    if ([self messageOwnerIsMyself]) {
        self.avatarView.frame = CGRectMake(self.qmui_width - 55, 10, 40, 40);
        self.characterView.frame = CGRectMake(self.qmui_width - 60, 5, 50, 50);
        self.levelLabel.frame = CGRectSetXY(self.levelLabel.frame, self.avatarView.qmui_left - 15 - self.levelLabel.qmui_width, 10);
        self.titleLabel.frame = CGRectSetXY(self.titleLabel.frame, self.levelLabel.qmui_left - 5 - self.titleLabel.qmui_width, 10);
        self.nameLabel.frame = CGRectSetXY(self.nameLabel.frame, self.avatarView.qmui_left - 15 - self.nameLabel.qmui_width, self.levelLabel.qmui_bottom + 5);
        self.timeLabel.frame = CGRectZero;
    } else {
        self.avatarView.frame = CGRectMake(15, 10, 40, 40);
        self.characterView.frame = CGRectMake(10, 5, 50, 50);
        self.levelLabel.frame = CGRectSetXY(self.levelLabel.frame, 70, 10);
        self.titleLabel.frame = CGRectSetXY(self.titleLabel.frame, self.levelLabel.qmui_right + 5, 10);
        self.timeLabel.frame = CGRectSetXY(self.timeLabel.frame, self.qmui_width - 10 - self.timeLabel.qmui_width, 10);
        self.nameLabel.frame = CGRectSetXY(self.nameLabel.frame, 70, self.levelLabel.qmui_bottom + 5);
    }
}

#pragma mark - Method
- (BOOL)messageOwnerIsMyself {
    return [self.message.user_id isEqualToString:self.myself.userId];
}

#pragma mark - Set
- (void)setMessage:(PCChatMessage *)message {
    _message = message;
    
    BOOL isMeself = [self messageOwnerIsMyself];
    self.messageBubbleView.arrowLeft = !isMeself;
    self.messageBubbleView.fillColor = isMeself ? UIColorBlue : PCColorLightPink;
    [self.avatarView pc_setImageWithURL:message.avatar placeholderImage:nil];
    [self.characterView pc_setImageWithURL:message.character placeholderImage:nil];
    NSString *gender = @"⚧";
    if ([message.gender isEqualToString:@"m"]) {
        gender = @"♂";
    } else if ([message.gender isEqualToString:@"f"]) {
        gender = @"♀";
    }
    self.levelLabel.text = [NSString stringWithFormat:@"%@ Lv.%@", gender, @(message.level)];
    self.titleLabel.text = message.title;
    self.nameLabel.text = message.name;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    [formatter setLocale:[NSLocale currentLocale]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@", message.platform ? message.platform : @"", [formatter stringFromDate:message.time]];
}

#pragma mark - Get
- (PCUser *)myself {
    if (!_myself) {
        _myself = [PCUser localUser];
    }
    return _myself;
}

- (UIImageView *)characterView {
    if (!_characterView) {
        _characterView = [[UIImageView alloc] init];
    }
    return _characterView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 20;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.borderWidth = .5;
        _avatarView.layer.borderColor = PCColorLightPink.CGColor;
    }
    return _avatarView;
}

- (QMUILabel *)levelLabel {
    if (!_levelLabel) {
        _levelLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:PCColorPink];
    }
    return _levelLabel;
}

- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorWhite];
        _titleLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        _titleLabel.backgroundColor = PCColorGold;
        _titleLabel.layer.cornerRadius = 7;
        _titleLabel.layer.masksToBounds = YES;
    }
    return _titleLabel;
}

- (QMUILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(11) textColor:UIColorGrayLighten];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (QMUILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorBlack];
    }
    return _nameLabel;
}

- (UIControl *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[UIControl alloc] init];
    }
    return _messageContentView;
}

- (PCMessageBubbleView *)messageBubbleView {
    if (!_messageBubbleView) {
        _messageBubbleView = [[PCMessageBubbleView alloc] init];
    }
    return _messageBubbleView;
}

@end
