//
//  PCNewChatMentionView.m
//  Pica
//
//  Created by 米画师 on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatMentionView.h"
#import "PCVendorHeader.h"
#import "PCCommonUI.h"

@interface PCNewChatMentionView ()

@property (nonatomic, strong) QMUIFloatLayoutView *contentView;
@property (nonatomic, strong) NSMutableArray      *userArray;

@end

@implementation PCNewChatMentionView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.backgroundColor = UIColor.systemGray6Color;
    [self addSubview:self.contentView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(SCREEN_WIDTH, [self.contentView sizeThatFits:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)].height);
}

- (void)addMentionUser:(PCUser *)user {
    [self.userArray addObject:user];
    [self.contentView addSubview:[self mentionViewWithUser:user]];
}

- (void)removeMentionUser:(PCUser *)user {
    NSInteger index = [self.userArray indexOfObject:user];
    [self.userArray removeObjectAtIndex:index];
    [self.contentView.subviews[index] removeFromSuperview];
}

- (void)clearMention {
    [self.userArray removeAllObjects];
    [self.contentView qmui_removeAllSubviews];
}

- (QMUIButton *)mentionViewWithUser:(PCUser *)user {
    QMUIButton *button = [[QMUIButton alloc] qmui_initWithImage:[UIImage systemImageNamed:@"xmark.circle"] title:user.name];
    button.imagePosition = QMUIButtonImagePositionRight;
    button.spacingBetweenImageAndTitle = 5;
    button.tintColor = UIColorBlack;
    button.titleLabel.font = UIFontMake(12);
    [button setTitleColor:UIColorBlack forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    button.backgroundColor = PCColorLightPink;
    button.layer.cornerRadius = 4;
    [button sizeToFit];
    button.qmui_outsideEdge = UIEdgeInsetsMake(0, button.qmui_width - 30, 0, 0);
    [button addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [button qmui_bindObject:user forKey:@"user"];
    
    return button;
}

- (void)deleteAction:(QMUIButton *)sender {
    PCUser *user = [sender qmui_getBoundObjectForKey:@"user"];
    [self removeMentionUser:user];
    !self.removeBlock ? : self.removeBlock(user);
}

#pragma mark - Get
- (QMUIFloatLayoutView *)contentView {
    if (!_contentView) {
        _contentView = [[QMUIFloatLayoutView alloc] init];
        _contentView.padding = UIEdgeInsetsMake(10, 15, 10, 15);
        _contentView.itemMargins = UIEdgeInsetsMake(0, 0, 10, 10);
    }
    return _contentView;
}

- (NSMutableArray *)userArray {
    if (!_userArray) {
        _userArray = [NSMutableArray array];
    }
    return _userArray;
}

@end
