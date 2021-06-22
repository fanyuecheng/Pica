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
         
        [self.messageContentView addSubview:self.replyLabel];
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
    
    if (message.at.length) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
        
        NSAttributedString *atString = [[NSAttributedString alloc] initWithString:[message.at stringByReplacingOccurrencesOfString:@"嗶咔_" withString:@"@"] attributes:@{NSFontAttributeName: UIFontMake(14), NSForegroundColorAttributeName: PCColorHotPink}];
        
        NSAttributedString *messageString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", message.message] attributes:@{NSFontAttributeName: UIFontMake(15), NSForegroundColorAttributeName: UIColorBlack}];
        
        [attributedText appendAttributedString:atString];
        [attributedText appendAttributedString:messageString];
        
        self.messageLabel.attributedText = attributedText;
    } else {
        self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:message.message attributes:@{NSFontAttributeName: UIFontMake(15), NSForegroundColorAttributeName:UIColorBlack}];
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
