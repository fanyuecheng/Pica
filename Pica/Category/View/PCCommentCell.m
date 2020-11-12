//
//  PCCommentCell.m
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCommentCell.h"
#import "PCVendorHeader.h"
#import "UIImageView+PCAdd.h"
#import "NSDate+PCAdd.h"
 
@interface PCCommentCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *characterView;
@property (nonatomic, strong) QMUILabel   *nameLabel;
@property (nonatomic, strong) QMUILabel   *levelLabel;
@property (nonatomic, strong) QMUILabel   *titleLabel;
@property (nonatomic, strong) QMUILabel   *contentLabel;
@property (nonatomic, strong) QMUILabel   *timeLabel;
@property (nonatomic, strong) QMUILabel   *likeLabel;
@property (nonatomic, strong) QMUILabel   *countLabel;

@end

@implementation PCCommentCell
 
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.characterView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.levelLabel];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.likeLabel];
        [self.contentView addSubview:self.countLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarView.frame = CGRectMake(15, 20, 80, 80);
    self.characterView.frame = CGRectMake(5, 10, 100, 100);
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectSetXY(self.nameLabel.bounds, 110, 20);
    [self.levelLabel sizeToFit];
    self.levelLabel.frame = CGRectSetXY(self.levelLabel.bounds, 110, self.nameLabel.qmui_bottom + 20);
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectSetXY(self.titleLabel.bounds, self.levelLabel.qmui_right + 15, self.levelLabel.qmui_top + (self.levelLabel.qmui_height - self.titleLabel.qmui_height) * 0.5);
    self.contentLabel.frame = CGRectMake(110, 80, SCREEN_WIDTH - 125, QMUIViewSelfSizingHeight);
    [self.timeLabel sizeToFit];
    self.timeLabel.frame = CGRectSetXY(self.timeLabel.bounds, 15, self.qmui_height -  self.timeLabel.qmui_height - 10);
    [self.countLabel sizeToFit];
    self.countLabel.frame = CGRectSetXY(self.countLabel.bounds, SCREEN_WIDTH - self.countLabel.qmui_width - 15, self.qmui_height - self.countLabel.qmui_height - 10);
    [self.likeLabel sizeToFit];
    self.likeLabel.frame = CGRectSetXY(self.likeLabel.bounds, self.countLabel.qmui_left - self.likeLabel.qmui_width - 10, self.countLabel.qmui_top);
}

- (void)setComment:(PCComment *)comment {
    _comment = comment;
     
    [self.avatarView pc_setImageWithURL:comment.user.avatar.imageURL];
    if (comment.user.character) {
        [self.characterView pc_setImageWithURL:comment.user.character placeholderImage:nil];
    }
    self.nameLabel.text = comment.user.name;
    self.titleLabel.text = comment.user.title;
    self.levelLabel.text = [NSString stringWithFormat:@"Lv.%@", @(comment.user.level)];
    self.contentLabel.text = comment.content;
    self.timeLabel.text = [comment.created_at pc_stringWithFormat:@"yyyy年MM月dd日"];
    self.likeLabel.text = [NSString stringWithFormat:@"❤ %@", @(comment.likesCount)];
    self.countLabel.text = [NSString stringWithFormat:@"子评论 %@", @(comment.commentsCount)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    height += 110 + [self.contentLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 125, CGFLOAT_MAX)].height + 20;
    return CGSizeMake(SCREEN_WIDTH, height);
}

#pragma mark - Get
- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 40;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.borderWidth = .5;
        _avatarView.layer.borderColor = UIColorMake(255, 105, 180).CGColor;
    }
    return _avatarView;
}

- (UIImageView *)characterView {
    if (!_characterView) {
        _characterView = [[UIImageView alloc] init];
    }
    return _characterView;
}

- (QMUILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontBoldMake(14) textColor:UIColorBlack];
    }
    return _nameLabel;
}

- (QMUILabel *)levelLabel {
    if (!_levelLabel) {
        _levelLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorMake(255, 105, 180)];
    }
    return _levelLabel;
}
 
- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(10) textColor:UIColorWhite];
        _titleLabel.backgroundColor = UIColorYellow;
        _titleLabel.layer.cornerRadius = 10;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.contentEdgeInsets = UIEdgeInsetsMake(3, 5, 3, 5);
    }
    return _titleLabel;
}
 
- (QMUILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorGrayDarken];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}
 
- (QMUILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorGray];
    }
    return _timeLabel;
}

- (QMUILabel *)likeLabel {
    if (!_likeLabel) {
        _likeLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorGray];
    }
    return _likeLabel;
}

- (QMUILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorGray];
    }
    return _countLabel;
}

@end
