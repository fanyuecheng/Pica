//
//  PCProfileHeaderView.m
//  Pica
//
//  Created by YueCheng on 2021/5/27.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCProfileHeaderView.h"
#import "PCVendorHeader.h"
#import "UIImage+PCAdd.h"
#import "UIImageView+PCAdd.h"
#import "PCCommonUI.h"
#import "PCUser.h"

@interface PCProfileHeaderView ()

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *characterView;
@property (nonatomic, strong) QMUILabel   *levelLabel;
@property (nonatomic, strong) QMUILabel   *nameLabel;
@property (nonatomic, strong) QMUILabel   *titleLabel;
@property (nonatomic, strong) QMUILabel   *sloganLabel;
@property (nonatomic, strong) QMUIButton  *signButton;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation PCProfileHeaderView

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
    [self addSubview:self.backgroundView];
    [self.layer addSublayer:self.gradientLayer];
    [self addSubview:self.avatarView];
    [self addSubview:self.characterView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.levelLabel];
    [self addSubview:self.titleLabel];
    [self addSubview:self.sloganLabel];
    [self addSubview:self.signButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    self.characterView.frame = CGRectMake((self.qmui_width - 140) * 0.5, 20, 140, 140);
    self.avatarView.frame = CGRectMake((self.qmui_width - 100) * 0.5, 40, 100, 100);
    self.nameLabel.frame = CGRectMake(10, self.characterView.qmui_bottom + 10, self.qmui_width - 20, QMUIViewSelfSizingHeight);
    self.levelLabel.frame = CGRectMake(10, self.nameLabel.qmui_bottom + 5, self.qmui_width - 20, QMUIViewSelfSizingHeight);
    self.titleLabel.frame = CGRectMake(10, self.levelLabel.qmui_bottom + 5, self.qmui_width - 20, QMUIViewSelfSizingHeight);
    self.sloganLabel.frame = CGRectMake(10, self.titleLabel.qmui_bottom + 5, self.qmui_width - 20, QMUIViewSelfSizingHeight);
    self.signButton.frame = CGRectMake(self.qmui_width - 60, 25, 45, 22);
    self.gradientLayer.frame = CGRectMake(0, self.qmui_height * 0.5, self.qmui_width, self.qmui_height * 0.5);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    
    height += 20 + 140 + 10 + [self.nameLabel sizeThatFits:CGSizeMax].height + 5 + [self.levelLabel sizeThatFits:CGSizeMax].height + 5 + [self.titleLabel sizeThatFits:CGSizeMax].height + 5 + [self.sloganLabel sizeThatFits:CGSizeMax].height + 10;
    
    return CGSizeMake(SCREEN_WIDTH, height);
}

- (void)setPunchInButtonHidden:(BOOL)hidden {
    self.signButton.hidden = hidden;
}

- (void)updateAvatar:(UIImage *)avatar {
    self.avatarView.image = avatar;
    self.backgroundView.image = [avatar sd_blurredImageWithRadius:10];
}

- (void)updateSlogan:(NSString *)slogan {
    self.sloganLabel.text = slogan;
}

#pragma mark - Action
- (void)punchInAction:(QMUIButton *)sender {
    !self.punchInBlock ? : self.punchInBlock();
}

- (void)avatarAction:(UITapGestureRecognizer *)sender {
    !self.avatarBlock ? : self.avatarBlock();
}

- (void)sloganAction:(UITapGestureRecognizer *)sender {
    !self.sloganBlock ? : self.sloganBlock();
}

#pragma mark - Get
- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundView.clipsToBounds = YES;
    }
    return _backgroundView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 50;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.clipsToBounds = YES;
    }
    return _avatarView;
}

- (UIImageView *)characterView {
    if (!_characterView) {
        _characterView = [[UIImageView alloc] init];
        _characterView.userInteractionEnabled = YES;
        [_characterView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarAction:)]];
    }
    return _characterView;
}

- (QMUILabel *)levelLabel {
    if (!_levelLabel) {
        _levelLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorWhite];
        _levelLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _levelLabel;
}

- (QMUILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorWhite];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorWhite];
        _titleLabel.textAlignment = NSTextAlignmentCenter; 
    }
    return _titleLabel;
}
 
- (QMUILabel *)sloganLabel {
    if (!_sloganLabel) {
        _sloganLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorWhite];
        _sloganLabel.textAlignment = NSTextAlignmentCenter;
        _sloganLabel.userInteractionEnabled = YES;
        [_sloganLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sloganAction:)]];
    }
    return _sloganLabel;
}
 
- (QMUIButton *)signButton {
    if (!_signButton) {
        _signButton = [[QMUIButton alloc] init];
        _signButton.titleLabel.font = UIFontMake(14);
        [_signButton setTitle:@"签到" forState:UIControlStateNormal];
        [_signButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        _signButton.layer.cornerRadius = 11;
        _signButton.layer.borderColor = UIColorWhite.CGColor;
        _signButton.layer.borderWidth = .5;
        [_signButton addTarget:self action:@selector(punchInAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signButton;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [[CAGradientLayer alloc] init];
        _gradientLayer.colors = @[(id)UIColorMakeWithRGBA(0, 0, 0, 0).CGColor, (id)UIColorMakeWithRGBA(0, 0, 0, 0.6).CGColor];
        _gradientLayer.locations = @[@0, @1];
        _gradientLayer.startPoint = CGPointMake(0.5, 0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1);
    }
    return _gradientLayer;
}
 
#pragma mark - Set
- (void)setUser:(PCUser *)user {
    _user = user;
    
    if (user.avatar) {
        [self.backgroundView pc_setImageWithURL:user.avatar.imageURL
                               placeholderImage:nil
                                        options:0
                                        context:@{SDWebImageContextImageTransformer : [SDImageBlurTransformer transformerWithRadius:10]}
                                       progress:nil
                                      completed:nil];
        [self.avatarView pc_setImageWithURL:user.avatar.imageURL];
    } else {
        self.avatarView.image = [UIImage qmui_imageWithColor:PCColorPink size:CGSizeMake(100, 100) cornerRadius:0];
        self.backgroundView.image = self.avatarView.image;
    }
    
    [self.characterView pc_setImageWithURL:user.character placeholderImage:nil];
    self.levelLabel.text = [NSString stringWithFormat:@"Lv.%zd exp:%zd", user.level, user.exp];
    self.nameLabel.text = user.name;
    self.titleLabel.text = user.title;
    self.sloganLabel.text = user.slogan;
    self.signButton.hidden = user.isPunched;
}

 
@end
