//
//  PCTextMessageCell.m
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCTextMessageCell.h"
#import "PCVendorHeader.h"
#import "PCCommonUI.h"
#import "PCChatMessage.h"
#import "PCMessageBubbleView.h"
#import "PCUser.h"
  
@implementation PCTextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
         
        [self.messageContentView addSubview:self.replyView];
        [self.replyView addSubview:self.replyNameLabel];
        [self.replyView addSubview:self.replyTextLabel];
        [self.messageContentView addSubview:self.messageLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
     
    /*
        10
     15-40-15-level-5-title
             5
             -name
             -content maxw = screenw-70-10
     */
    
    /* content maxw = screenw-70-10 textw =
        5
        5
   10-5-replyname
        5
        reply
        5
        5
        message
        10
     */
    CGFloat replyMaxWidth = self.qmui_width - 70 - 10 - 10 - 10 - 6;
    CGFloat messageMaxWidth = replyMaxWidth + 10;
    CGSize replyNameSize = [self.replyNameLabel sizeThatFits:CGSizeMake(replyMaxWidth, CGFLOAT_MAX)];
    CGSize replyTextSize = [self.replyTextLabel sizeThatFits:CGSizeMake(replyMaxWidth, CGFLOAT_MAX)];
    CGSize messageSize = [self.messageLabel sizeThatFits:CGSizeMake(messageMaxWidth, CGFLOAT_MAX)];
    
    CGFloat contentMaxWidth = MAX(MAX(replyNameSize.width, replyTextSize.width), messageSize.width);
    BOOL replayMax = MAX(replyNameSize.width, replyTextSize.width) > messageSize.width;
    if ([self messageOwnerIsMyself]) {
        if (self.message.reply.length) {
            self.replyNameLabel.frame = CGRectMake(5, 5, replyNameSize.width, QMUIViewSelfSizingHeight);
            self.replyTextLabel.frame = CGRectMake(5, self.replyNameLabel.qmui_bottom + 5, replyTextSize.width, QMUIViewSelfSizingHeight);
            self.replyView.frame = CGRectMake(6, 6, contentMaxWidth + (replayMax ? 10 : 0), self.replyTextLabel.qmui_bottom + 5);
        } else {
            self.replyView.frame = CGRectMake(6, 6, contentMaxWidth, 0);
        }
        self.messageLabel.frame = CGRectMake(6, self.replyView.qmui_bottom + (self.message.reply.length ? 5 : 0), contentMaxWidth, QMUIViewSelfSizingHeight);
        self.messageContentView.frame = CGRectMake(self.qmui_width - 70 - (self.replyView.qmui_right + 10), self.nameLabel.qmui_bottom + 5, self.replyView.qmui_right + 10, self.messageLabel.qmui_bottom + 6);
    } else {
        if (self.message.reply.length) {
            self.replyNameLabel.frame = CGRectMake(5, 5, replyNameSize.width, QMUIViewSelfSizingHeight);
            self.replyTextLabel.frame = CGRectMake(5, self.replyNameLabel.qmui_bottom + 5, replyTextSize.width, QMUIViewSelfSizingHeight);
            self.replyView.frame = CGRectMake(10, 6, contentMaxWidth + (replayMax ? 10 : 0), self.replyTextLabel.qmui_bottom + 5);
        } else {
            self.replyView.frame = CGRectMake(10, 6, contentMaxWidth, 0);
        }
        self.messageLabel.frame = CGRectMake(10, self.replyView.qmui_bottom + (self.message.reply.length ? 5 : 0), contentMaxWidth, QMUIViewSelfSizingHeight);
        self.messageContentView.frame = CGRectMake(70, self.nameLabel.qmui_bottom + 5, self.replyView.qmui_right + 6, self.messageLabel.qmui_bottom + 6);
    }
    self.messageBubbleView.frame = self.messageContentView.frame;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = 10 + [self.levelLabel sizeThatFits:CGSizeMax].height + 5 + [self.nameLabel sizeThatFits:CGSizeMax].height + 5;
    h += 6;
    
    CGFloat replyMaxWidth = SCREEN_WIDTH - 70 - 10 - 10 - 10 - 6;
    CGFloat messageMaxWidth = replyMaxWidth + 10;
    CGSize replyNameSize = [self.replyNameLabel sizeThatFits:CGSizeMake(replyMaxWidth, CGFLOAT_MAX)];
    CGSize replyTextSize = [self.replyTextLabel sizeThatFits:CGSizeMake(replyMaxWidth, CGFLOAT_MAX)];
    CGSize messageSize = [self.messageLabel sizeThatFits:CGSizeMake(messageMaxWidth, CGFLOAT_MAX)];
    CGFloat contentMaxWidth = MAX(MAX(replyNameSize.width, replyTextSize.width), messageSize.width);
    if (self.message.reply.length) {
        h += 5 + [self.replyNameLabel sizeThatFits:CGSizeMake(contentMaxWidth, CGFLOAT_MAX)].height + 5 + [self.replyTextLabel sizeThatFits:CGSizeMake(contentMaxWidth, CGFLOAT_MAX)].height + 5 + 5;
    }
    
    h += [self.messageLabel sizeThatFits:CGSizeMake(contentMaxWidth, CGFLOAT_MAX)].height + 6 + 10;
    
    return CGSizeMake(SCREEN_WIDTH, h);
}

- (void)setMessage:(PCChatMessage *)message {
    [super setMessage:message];
    
    if (message.at.length) {
        NSString *atString = [message.at stringByReplacingOccurrencesOfString:@"嗶咔_" withString:@""];
        self.messageLabel.text = [NSString stringWithFormat:@"@%@\n%@", atString, message.message];
    } else {
        self.messageLabel.text = message.message;
    }
    self.replyNameLabel.text = message.reply_name;
    self.replyTextLabel.text = message.reply;
    self.replyView.hidden = message.reply.length == 0;
}

#pragma mark - Get
- (UIView *)replyView {
    if (!_replyView) {
        _replyView = [[UIView alloc] init];
        _replyView.backgroundColor = PCColorHotPink;
        _replyView.layer.cornerRadius = 4;
        _replyView.layer.masksToBounds = YES;
    }
    return _replyView;
}

- (QMUILabel *)replyNameLabel {
    if (!_replyNameLabel) {
        _replyNameLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(10) textColor:UIColorBlack];
    }
    return _replyNameLabel;
}

- (QMUILabel *)replyTextLabel {
    if (!_replyTextLabel) {
        _replyTextLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorBlack];
        _replyTextLabel.numberOfLines = 0;
    }
    return _replyTextLabel;
}

- (QMUILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorBlack];
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}

@end
