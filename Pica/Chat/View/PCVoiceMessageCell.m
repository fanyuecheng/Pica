//
//  PCVoiceMessageCell.m
//  Pica
//
//  Created by Fancy on 2021/6/17.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCVoiceMessageCell.h"
#import "PCVendorHeader.h"
#import "PCDefineHeader.h"
#import "PCMessageBubbleView.h"
#import "PCChatMessage.h"

@interface PCVoiceMessageCell ()

@property (nonatomic, strong) QMUIButton *playButton;
@property (nonatomic, strong) QMUILabel  *durationLabel;

@end

@implementation PCVoiceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.messageContentView addSubview:self.playButton];
        [self.messageContentView addSubview:self.durationLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if ([self messageOwnerIsMyself]) {
        self.durationLabel.frame = CGRectMake(116 - 50, 0, 50, 50);
        self.playButton.frame = CGRectMake(6, 0, 50, 50);
        self.messageContentView.frame = CGRectMake(SCREEN_WIDTH - 70 - 116, self.nameLabel.qmui_bottom + 5, 116, 50);
    } else {
        self.playButton.frame = CGRectMake(10, 0, 50, 50);
        self.durationLabel.frame = CGRectMake(60, 0, 50, 50);
        self.messageContentView.frame = CGRectMake(70, self.nameLabel.qmui_bottom + 5, 116, 50);
    }
    self.messageBubbleView.frame = self.messageContentView.frame;
}

- (void)setMessage:(PCChatMessage *)message {
    [super setMessage:message];
  
    self.durationLabel.text = [NSString stringWithFormat:@"%.2fs", message.audioPlayer.duration];
    self.playButton.selected = message.isPlaying;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 10 + [self.levelLabel sizeThatFits:CGSizeMax].height + 5 + [self.nameLabel sizeThatFits:CGSizeMax].height + 5;
    height += 50 + 10;
    return CGSizeMake(SCREEN_WIDTH, height);
}

#pragma mark - Action
- (void)playAction:(QMUIButton *)sender {
    sender.selected = !sender.selected;
    
    if (!self.message.playStateBlock) {
        @weakify(self)
        self.message.playStateBlock = ^(BOOL isPlaying) {
            @strongify(self)
            self.playButton.selected = isPlaying;
        };
    } 
    
    if (sender.selected) {
        [self.message playVoiceMessage];
    } else {
        [self.message pauseVoiceMessage];
    }
}
 

#pragma mark - Get
- (QMUIButton *)playButton {
    if (!_playButton) {
        _playButton = [[QMUIButton alloc] init];
        _playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _playButton.titleLabel.font = UIFontMake(20);
        [_playButton setTitle:@"▶️" forState:UIControlStateNormal];
        [_playButton setTitle:@"⏸" forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (QMUILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorBlack];
    }
    return _durationLabel;
}

@end
