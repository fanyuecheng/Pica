//
//  PCUserInfoView.m
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCUserInfoView.h"
#import "PCVendorHeader.h"
#import "UIImageView+PCAdd.h"

@interface PCUserInfoView ()

@property (nonatomic, strong) QMUILabel   *levelLabel;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *characterView;
@property (nonatomic, strong) QMUILabel   *nameLabel;
@property (nonatomic, strong) QMUILabel   *titleLabel;
@property (nonatomic, strong) QMUILabel   *sloganLabel;

@end

@implementation PCUserInfoView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.backgroundColor = UIColorWhite;
    self.layer.cornerRadius = 6; 
    
    [self addSubview:self.levelLabel];
    [self addSubview:self.avatarView];
    [self addSubview:self.characterView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.titleLabel];
    [self addSubview:self.sloganLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.levelLabel.frame = CGRectMake(0, 10, self.qmui_width, QMUIViewSelfSizingHeight);
    self.avatarView.frame = CGRectMake((self.qmui_width - 80) * 0.5, self.levelLabel.qmui_bottom + 15, 80, 80);
    self.characterView.frame = CGRectMake((self.qmui_width - 100) * 0.5, self.levelLabel.qmui_bottom + 5, 100, 100);
    self.nameLabel.frame = CGRectMake(0, self.characterView.qmui_bottom + 5, self.qmui_width, QMUIViewSelfSizingHeight);
    self.titleLabel.frame = CGRectMake(0, self.nameLabel.qmui_bottom + 5, self.qmui_width, QMUIViewSelfSizingHeight);
    self.sloganLabel.frame = CGRectMake(10, self.titleLabel.qmui_bottom + 5, self.qmui_width - 20, QMUIViewSelfSizingHeight);
}

- (void)setUser:(PCUser *)user {
    _user = user;
    
    self.levelLabel.text = [NSString stringWithFormat:@"Lv.%@", @(user.level)];
    [self.avatarView pc_setImageWithURL:user.avatar.imageURL];
    if (user.character) {
        [self.characterView pc_setImageWithURL:user.character placeholderImage:nil];
    }
    self.nameLabel.text = user.name;
    self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)", user.title, [user.gender isEqualToString:@"m"] ? @"绅士" : @"淑女"];
    self.sloganLabel.text = user.slogan;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    
    height += 10 + [self.levelLabel sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)].height + 5 + 100 + 5 + [self.nameLabel sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)].height + 5 + [self.titleLabel sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)].height + 5 + [self.sloganLabel sizeThatFits:CGSizeMake(size.width - 20, CGFLOAT_MAX)].height + 20;
    
    return CGSizeMake(size.width, height);
}

#pragma mark - Get
- (QMUILabel *)levelLabel {
    if (!_levelLabel) {
        _levelLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorBlack];
        _levelLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _levelLabel;
}

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
        _nameLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorBlack];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorMake(255, 105, 180)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (QMUILabel *)sloganLabel {
    if (!_sloganLabel) {
        _sloganLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorGray];
        _sloganLabel.textAlignment = NSTextAlignmentCenter;
        _sloganLabel.numberOfLines = 0;
    }
    return _sloganLabel;
}

@end
