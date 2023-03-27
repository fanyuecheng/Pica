//
//  PCNewChatMessageCell.m
//  Pica
//
//  Created by Fancy on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatMessageCell.h"
#import "PCVendorHeader.h"
#import "PCCommonUI.h"
#import "PCUser.h"
#import "UIImageView+PCAdd.h"
#import "PCProfileRequest.h"
#import "PCDefineHeader.h"
#import "PCUserInfoView.h"
#import "PCPopupContainerView.h"

@interface PCNewChatMessageCell ()

@property (nonatomic, strong) PCUser           *myself;
@property (nonatomic, strong) PCProfileRequest *request;

@end

@implementation PCNewChatMessageCell

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

#pragma mark - Action
- (void)avatarAction:(UITapGestureRecognizer *)sender {
    if (self.message && ![self messageOwnerIsMyself]) {
        if (self.message.profile) {
            [self showUserInfo:self.message.profile];
        } else {
            self.request.userId = self.message.profile.userId;
            @weakify(self)
            [self.request sendRequest:^(PCUser *user) {
                @strongify(self)
                self.message.profile = user;
                [self showUserInfo:user];
            } failure:nil];
        }
    }
}

#pragma mark - Method
- (BOOL)messageOwnerIsMyself {
    return [self.message.profile.userId isEqualToString:self.myself.userId];
}

- (void)showUserInfo:(PCUser *)user {
    QMUIModalPresentationViewController *controller = [[QMUIModalPresentationViewController alloc] init];
    PCUserInfoView *infoView = [[PCUserInfoView alloc] init];
    infoView.user = user;
    controller.contentView = infoView;
    [controller showWithAnimated:YES completion:nil];
}

#pragma mark - Set
- (void)setMessage:(PCNewChatMessage *)message {
    _message = message;
    
    [self.avatarView pc_setImageWithURL:message.profile.avatarUrl placeholderImage:nil];
    [self.characterView pc_setImageWithURL:message.profile.character placeholderImage:nil];
    NSString *gender = @"⚧";
    if ([message.profile.gender isEqualToString:@"m"]) {
        gender = @"♂";
    } else if ([message.profile.gender isEqualToString:@"f"]) {
        gender = @"♀";
    }
    self.levelLabel.text = [NSString stringWithFormat:@"%@ Lv.%@", gender, @(message.profile.level)];
    self.titleLabel.text = message.profile.title;
    self.nameLabel.text = message.profile.name;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    [formatter setLocale:[NSLocale currentLocale]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:message.date]];
}

#pragma mark - Action
- (void)menuAction:(UIControl *)sender {
    if (!self.message || [self messageOwnerIsMyself]) {
        return;
    }
    PCPopupContainerView *popupView = [[PCPopupContainerView alloc] init];
    popupView.preferLayoutDirection = QMUIPopupContainerViewLayoutDirectionAbove;
    popupView.automaticallyHidesWhenUserTap = YES;
    popupView.sourceView = sender;
    popupView.titleArray = @[@"复制"];
    @weakify(self)
    popupView.actionBlock = ^(PCPopupContainerView *view, NSInteger index) {
        @strongify(self)
        switch (index) {
            case 0:{
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = self.message.message;
                break;}
                break;
            default:
                break;
        }
        [view hideWithAnimated:YES];
    };
    [popupView showWithAnimated:YES];
}

- (void)atAction:(id)sender {
    !self.atBlock ? : self.atBlock(self.message);
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
        _characterView.userInteractionEnabled = YES;
        [_characterView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarAction:)]];
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
        _titleLabel.userInteractionEnabled = YES;
        [_titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(atAction:)]];
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
        _nameLabel.userInteractionEnabled = YES;
        [_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(atAction:)]];
    }
    return _nameLabel;
}

- (UIControl *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[UIControl alloc] init];
        [_messageContentView addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageContentView;
}

- (PCNewChatMessageBubbleView *)messageBubbleView {
    if (!_messageBubbleView) {
        _messageBubbleView = [[PCNewChatMessageBubbleView alloc] init];
    }
    return _messageBubbleView;
}

- (PCProfileRequest *)request {
    if (!_request) {
        _request = [[PCProfileRequest alloc] init];
    }
    return _request;
}

@end
