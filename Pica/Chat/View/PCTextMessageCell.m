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

@interface PCPopupContainerView : QMUIPopupContainerView

@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, copy)   void (^actionBlock)(PCPopupContainerView *view, NSInteger index);

@end

@implementation PCPopupContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentEdgeInsets = UIEdgeInsetsZero;
        self.buttonArray = [NSMutableArray array];
        NSArray *array = @[@"复制", @"回复", @"@"];
        [array enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
            QMUIButton *button = [[QMUIButton alloc] init];
            button.tag = idx + 1000;
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:UIColorBlue forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
            [self.buttonArray addObject:button];
        }];
    } 
    return self;
}

- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    return CGSizeMake(180, 40);
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    [self.buttonArray enumerateObjectsUsingBlock:^(QMUIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(60 * idx, 0, 60, 40);
    }];
}

- (void)buttonAction:(QMUIButton *)sender {
    !self.actionBlock ? : self.actionBlock(self, sender.tag - 1000);
}

@end

  
@implementation PCTextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
         
        [self.messageContentView addSubview:self.replyView];
        [self.replyView addSubview:self.replyNameLabel];
        [self.replyView addSubview:self.replyTextLabel];
        [self.messageContentView addSubview:self.messageLabel];
        [self.messageContentView addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
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
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
        
        NSAttributedString *atString = [[NSAttributedString alloc] initWithString:[message.at stringByReplacingOccurrencesOfString:@"嗶咔_" withString:@"@"] attributes:@{NSFontAttributeName: UIFontMake(14), NSForegroundColorAttributeName: PCColorHotPink}];
        
        NSAttributedString *messageString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", message.message] attributes:@{NSFontAttributeName: UIFontMake(15), NSForegroundColorAttributeName: UIColorBlack}];
        
        [attributedText appendAttributedString:atString];
        [attributedText appendAttributedString:messageString];
        
        self.messageLabel.attributedText = attributedText;
    } else {
        self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:message.message attributes:@{NSFontAttributeName: UIFontMake(15), NSForegroundColorAttributeName: UIColorBlack}];
    }
    self.replyNameLabel.text = message.reply_name;
    self.replyTextLabel.text = message.reply;
    self.replyView.hidden = message.reply.length == 0;
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
        _messageLabel = [[QMUILabel alloc] init];
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}

@end
