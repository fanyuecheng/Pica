//
//  PCNewChatRoomCell.m
//  Pica
//
//  Created by Fancy on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatRoomCell.h"
#import "PCNewChatRoom.h"
#import "UIImageView+PCAdd.h"

@interface PCNewChatRoomCell ()

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) QMUILabel   *titleLabel;
@property (nonatomic, strong) QMUILabel   *detailLabel;

@end

@implementation PCNewChatRoomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.coverView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverView.frame = CGRectMake(15, 10, self.qmui_height - 20, self.qmui_height - 20);
    self.titleLabel.frame = CGRectMake(self.coverView.qmui_right + 10, 10, self.qmui_width - self.coverView.qmui_right - 20, QMUIViewSelfSizingHeight);
    self.detailLabel.frame = CGRectMake(self.coverView.qmui_right + 10, self.titleLabel.qmui_bottom + 5, self.qmui_width - self.coverView.qmui_right - 20, QMUIViewSelfSizingHeight);
}

- (void)setRoom:(PCNewChatRoom *)room {
    [self.coverView pc_setImageWithURL:room.icon];
    self.titleLabel.text = room.title;
    self.detailLabel.text = [NSString stringWithFormat:@"等级限制：%@   注册日数限制：%@",   @(room.minLevel), @(room.minRegisterDays)];
}

#pragma mark - Get
- (UIImageView *)coverView {
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.layer.cornerRadius = 4;
        _coverView.layer.masksToBounds = YES;
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _coverView;
}

- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorBlack];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (QMUILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(11) textColor:UIColorGray];
        _detailLabel.numberOfLines = 0;
    }
    return _detailLabel;
}

@end
