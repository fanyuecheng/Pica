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
#import "PCDefineHeader.h"
#import "PCPopupContainerView.h"

@implementation PCTextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
         
        [self.messageContentView addSubview:self.replyLabel];
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
    CGFloat textMaxWidth = self.qmui_width - 70 - 10 - 10 - 6;
    CGSize replySize = [self.replyLabel sizeThatFits:CGSizeMake(textMaxWidth, CGFLOAT_MAX)];
    CGSize messageSize = [self.messageLabel sizeThatFits:CGSizeMake(textMaxWidth, CGFLOAT_MAX)];
    
    CGFloat contentMaxWidth = MAX(replySize.width, messageSize.width);
     
    if ([self messageOwnerIsMyself]) {
        if (self.message.reply.length) {
            self.replyLabel.frame = CGRectMake(6, 6, contentMaxWidth, QMUIViewSelfSizingHeight);
        } else {
            self.replyLabel.frame = CGRectMake(6, 6, contentMaxWidth, 0);
        }
        self.messageLabel.frame = CGRectMake(6, self.replyLabel.qmui_bottom + (self.message.reply.length ? 5 : 0), contentMaxWidth, QMUIViewSelfSizingHeight);
        self.messageContentView.frame = CGRectMake(self.qmui_width - 70 - (self.replyLabel.qmui_right + 10), self.nameLabel.qmui_bottom + 5, self.replyLabel.qmui_right + 10, self.messageLabel.qmui_bottom + 6);
    } else {
        if (self.message.reply.length) {
            self.replyLabel.frame = CGRectMake(10, 6, contentMaxWidth, QMUIViewSelfSizingHeight);
        } else {
            self.replyLabel.frame = CGRectMake(10, 6, contentMaxWidth, 0);
        }
        self.messageLabel.frame = CGRectMake(10, self.replyLabel.qmui_bottom + (self.message.reply.length ? 5 : 0), contentMaxWidth, QMUIViewSelfSizingHeight);
        self.messageContentView.frame = CGRectMake(70, self.nameLabel.qmui_bottom + 5, self.replyLabel.qmui_right + 6, self.messageLabel.qmui_bottom + 6);
    }
    self.messageBubbleView.frame = self.messageContentView.frame;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = 10 + [self.levelLabel sizeThatFits:CGSizeMax].height + 5 + [self.nameLabel sizeThatFits:CGSizeMax].height + 5;
    h += 6;
    
    CGFloat textMaxWidth = SCREEN_WIDTH - 70 - 10 - 10 - 6;
    if (self.message.reply.length) {
        h += 5 + [self.replyLabel sizeThatFits:CGSizeMake(textMaxWidth, CGFLOAT_MAX)].height + 5;
    }
    
    h += [self.messageLabel sizeThatFits:CGSizeMake(textMaxWidth, CGFLOAT_MAX)].height + 6 + 10;
    
    return CGSizeMake(SCREEN_WIDTH, h);
}

- (void)setMessage:(PCChatMessage *)message {
    [super setMessage:message];
    
    BOOL color = [kPCUserDefaults boolForKey:PC_CHAT_EVENT_COLOR_ON];

    if (message.at.length) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
        
        NSAttributedString *atString = [[NSAttributedString alloc] initWithString:[message.at stringByReplacingOccurrencesOfString:@"嗶咔_" withString:@"@"] attributes:@{NSFontAttributeName: UIFontMake(14), NSForegroundColorAttributeName: PCColorHotPink}];
        
        NSString *msgString = [NSString stringWithFormat:@"\n%@", message.message];
        NSAttributedString *messageString = message.event_colors.count && color ? [self colorAttributedStringWithText:msgString colorArray:message.eventColorArray] : [self normalAttributedStringWithText:msgString];
        
        [attributedText appendAttributedString:atString];
        [attributedText appendAttributedString:messageString];
        
        self.messageLabel.attributedText = attributedText;
    } else {
        self.messageLabel.attributedText = message.event_colors.count && color ? [self colorAttributedStringWithText:message.message colorArray:message.eventColorArray] : [self normalAttributedStringWithText:message.message];
    }
     
    self.replyLabel.hidden = message.reply.length == 0;
    if (message.reply.length) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
        
        NSAttributedString *nameString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", message.reply_name] attributes:@{NSFontAttributeName: UIFontMake(10), NSForegroundColorAttributeName:UIColorBlack}];
        NSAttributedString *replyString = [[NSAttributedString alloc] initWithString:message.reply attributes:@{NSFontAttributeName: UIFontMake(12), NSForegroundColorAttributeName:UIColorBlack}];
        
        [attributedText appendAttributedString:nameString];
        [attributedText appendAttributedString:replyString];
        
        self.replyLabel.attributedText = attributedText;
    } else {
        self.replyLabel.attributedText = nil;
    }
}

#pragma mark - Method
- (NSAttributedString *)normalAttributedStringWithText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: UIFontMake(15), NSForegroundColorAttributeName:UIColorBlack}];
}

- (NSAttributedString *)colorAttributedStringWithText:(NSString *)text
                                           colorArray:(NSArray *)colorArray {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttributes:@{NSFontAttributeName: UIFontMake(15)} range:NSMakeRange(0, text.length)];
    
 
    NSMutableArray *colors = [NSMutableArray array];
    do {
        [colors addObjectsFromArray:colorArray];
    } while (colors.count < text.length);
   
    
    for (NSInteger i = 0; i < attributedString.string.length; i++) {
        NSRange range = [text rangeOfComposedCharacterSequenceAtIndex:i];
        [attributedString addAttributes:@{NSForegroundColorAttributeName: colors[i]} range:range];
    }
    
    return attributedString;
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
    popupView.titleArray = @[@"复制", @"回复", @"@"];
    @weakify(self)
    popupView.actionBlock = ^(PCPopupContainerView *view, NSInteger index) {
        @strongify(self)
        switch (index) {
            case 0:{
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = self.message.message;
                break;}
            case 1:
                !self.replayBlock ? : self.replayBlock(self.message);
                break;
            case 2:
                !self.atBlock ? : self.atBlock(self.message);
                break;
            default:
                break;
        }
        [view hideWithAnimated:YES];
    };
    [popupView showWithAnimated:YES];
}

#pragma mark - Get
 
- (QMUILabel *)replyLabel {
    if (!_replyLabel) {
        _replyLabel = [[QMUILabel alloc] init];
        _replyLabel.numberOfLines = 0;
        _replyLabel.backgroundColor = PCColorHotPink;
        _replyLabel.layer.cornerRadius = 4;
        _replyLabel.layer.masksToBounds = YES;
        _replyLabel.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    }
    return _replyLabel;
}

- (QMUILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[QMUILabel alloc] init];
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}

@end
