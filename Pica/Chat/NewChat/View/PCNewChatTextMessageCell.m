//
//  PCNewChatTextMessageCell.m
//  Pica
//
//  Created by Fancy on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatTextMessageCell.h"
#import "PCVendorHeader.h"
#import "PCCommonUI.h"
#import "PCChatMessage.h"
#import "PCMessageBubbleView.h"
#import "PCUser.h"
#import "PCDefineHeader.h"

@implementation PCNewChatTextMessageCell

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
    BOOL hasReply = self.message.replyMessage || self.message.replyImage;
    if ([self messageOwnerIsMyself]) {
        if (hasReply) {
            self.replyLabel.frame = CGRectMake(6, 6, contentMaxWidth, QMUIViewSelfSizingHeight);
        } else {
            self.replyLabel.frame = CGRectMake(6, 6, contentMaxWidth, 0);
        }
        self.messageLabel.frame = CGRectMake(6, self.replyLabel.qmui_bottom + (hasReply ? 5 : 0), contentMaxWidth, QMUIViewSelfSizingHeight);
        self.messageContentView.frame = CGRectMake(self.qmui_width - 70 - (self.replyLabel.qmui_right + 10), self.nameLabel.qmui_bottom + 5, self.replyLabel.qmui_right + 10, self.messageLabel.qmui_bottom + 6);
    } else {
        if (hasReply) {
            self.replyLabel.frame = CGRectMake(10, 6, contentMaxWidth, QMUIViewSelfSizingHeight);
        } else {
            self.replyLabel.frame = CGRectMake(10, 6, contentMaxWidth, 0);
        }
        self.messageLabel.frame = CGRectMake(10, self.replyLabel.qmui_bottom + (self.message.replyMessage || self.message.replyImage ? 5 : 0), contentMaxWidth, QMUIViewSelfSizingHeight);
        self.messageContentView.frame = CGRectMake(70, self.nameLabel.qmui_bottom + 5, self.replyLabel.qmui_right + 6, self.messageLabel.qmui_bottom + 6);
    }
    self.messageBubbleView.frame = self.messageContentView.frame;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = 10 + [self.levelLabel sizeThatFits:CGSizeMax].height + 5 + [self.nameLabel sizeThatFits:CGSizeMax].height + 5;
    h += 6;
    
    CGFloat textMaxWidth = SCREEN_WIDTH - 70 - 10 - 10 - 6;
    if (self.message.replyMessage || self.message.replyImage) {
        h += 5 + [self.replyLabel sizeThatFits:CGSizeMake(textMaxWidth, CGFLOAT_MAX)].height + 5;
    }
    
    h += [self.messageLabel sizeThatFits:CGSizeMake(textMaxWidth, CGFLOAT_MAX)].height + 6 + 10;
    
    return CGSizeMake(SCREEN_WIDTH, h);
}

- (void)setMessage:(PCNewChatMessage *)message {
    [super setMessage:message];
      
    if (message.userMentions.count) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
        
        [message.userMentions enumerateObjectsUsingBlock:^(PCUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSAttributedString *atString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@ ", obj.name] attributes:@{NSFontAttributeName: UIFontMake(14), NSForegroundColorAttributeName: PCColorHotPink}];
            [attributedText appendAttributedString:atString];
        }];
        
        NSString *msgString = [NSString stringWithFormat:@"\n%@", message.message];
        NSAttributedString *messageString = [self normalAttributedStringWithText:msgString];
        [attributedText appendAttributedString:messageString];
        self.messageLabel.attributedText = attributedText;
    } else {
        self.messageLabel.attributedText = [self normalAttributedStringWithText:message.message];
    }
     
    self.replyLabel.hidden = !(message.replyMessage || message.replyImage);
    if (message.replyMessage || message.replyImage) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
        
        NSAttributedString *nameString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", message.replyUserName] attributes:@{NSFontAttributeName: UIFontMake(10), NSForegroundColorAttributeName:UIColorBlack}];
        NSAttributedString *replyString = [[NSAttributedString alloc] initWithString:message.replyMessage ? message.replyMessage : @"图片" attributes:@{NSFontAttributeName: UIFontMake(12), NSForegroundColorAttributeName:UIColorBlack}];
        
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
