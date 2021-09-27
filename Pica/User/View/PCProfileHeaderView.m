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
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    self.characterView.frame = CGRectMake(0, 0, 140, 140);
    self.avatarView.frame = CGRectMake(20, 20, 100, 100);
    self.nameLabel.frame = CGRectMake(self.characterView.qmui_right + 10, self.avatarView.qmui_top + 10, self.qmui_width - 160, QMUIViewSelfSizingHeight);
    self.levelLabel.frame = CGRectMake(self.nameLabel.qmui_left, self.nameLabel.qmui_bottom + 15, self.nameLabel.qmui_width, QMUIViewSelfSizingHeight);
    self.titleLabel.frame = CGRectMake(self.nameLabel.qmui_left, self.levelLabel.qmui_bottom + 15, self.nameLabel.qmui_width, QMUIViewSelfSizingHeight);
    self.sloganLabel.frame = CGRectMake(20, self.characterView.qmui_bottom + 10, self.qmui_width - 40, QMUIViewSelfSizingHeight);
    self.gradientLayer.frame = CGRectMake(0, self.qmui_height * 0.5, self.qmui_width, self.qmui_height * 0.5);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    
    height += 140 + 10 + [self.sloganLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 40, CGFLOAT_MAX)].height + 20;
     
    return CGSizeMake(SCREEN_WIDTH, height);
}

- (void)updateAvatar:(UIImage *)avatar {
    self.avatarView.image = avatar;
    self.backgroundView.image = [avatar sd_blurredImageWithRadius:10];
    [self configLabelWithImage:avatar];
}

- (void)updateSlogan:(NSString *)slogan {
    self.sloganLabel.text = slogan;
}

- (void)configLabelWithImage:(UIImage *)image {
    BOOL dark = image.qmui_averageColor.qmui_colorIsDark;
    UIColor *textColor = dark ? UIColorWhite : UIColorGray;
    self.titleLabel.textColor = textColor;
    self.nameLabel.textColor = textColor;
    self.levelLabel.textColor = textColor;
    self.sloganLabel.textColor = textColor;
}

#pragma mark - Action

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
        _levelLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorBlack];
    }
    return _levelLabel;
}

- (QMUILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorBlack];
    }
    return _nameLabel;
}

- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorBlack];
    }
    return _titleLabel;
}
 
- (QMUILabel *)sloganLabel {
    if (!_sloganLabel) {
        _sloganLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorBlack];
        _sloganLabel.numberOfLines = 0;
        _sloganLabel.userInteractionEnabled = YES;
        [_sloganLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sloganAction:)]];
    }
    return _sloganLabel;
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
                                      completed:^(UIImage * _Nonnull image, NSError * _Nonnull error) {
            [self configLabelWithImage:image];
        }];
        [self.avatarView pc_setImageWithURL:user.avatar.imageURL];
    } else {
        self.avatarView.image = [UIImage qmui_imageWithColor:PCColorPink size:CGSizeMake(100, 100) cornerRadius:0];
        self.backgroundView.image = self.avatarView.image;
    }
    
    [self.characterView pc_setImageWithURL:user.character placeholderImage:nil];
    self.levelLabel.text = [NSString stringWithFormat:@"Lv.%zd exp:%zd", user.level, user.exp];
    self.nameLabel.text = user.name;
    self.titleLabel.text = user.title;
    self.sloganLabel.text = user.slogan ? user.slogan : @"no slogan";
}

 
@end
