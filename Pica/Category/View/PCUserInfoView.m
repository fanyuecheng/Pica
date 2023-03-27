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
#import "PCCommonUI.h"
#import "PCDefineHeader.h"
#import "UIViewController+PCAdd.h"

@interface PCUserInfoView () <QMUIZoomImageViewDelegate>

@property (nonatomic, strong) QMUILabel   *levelLabel;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *characterView;
@property (nonatomic, strong) QMUILabel   *nameLabel;
@property (nonatomic, strong) QMUIMarqueeLabel *titleLabel;
@property (nonatomic, strong) QMUITextView *sloganView;
@property (nonatomic, strong) QMUIZoomImageView *previewView;

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
    [self addSubview:self.sloganView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.levelLabel.frame = CGRectMake(0, 10, self.qmui_width, QMUIViewSelfSizingHeight);
    self.avatarView.frame = CGRectMake((self.qmui_width - 80) * 0.5, self.levelLabel.qmui_bottom + 15, 80, 80);
    self.characterView.frame = CGRectMake((self.qmui_width - 100) * 0.5, self.levelLabel.qmui_bottom + 5, 100, 100);
    self.nameLabel.frame = CGRectMake(0, self.characterView.qmui_bottom + 5, self.qmui_width, QMUIViewSelfSizingHeight);
    self.titleLabel.frame = CGRectMake(0, self.nameLabel.qmui_bottom + 5, self.qmui_width, QMUIViewSelfSizingHeight);
    CGSize sloganSize = [self.sloganView sizeThatFits:CGSizeMake(self.qmui_width, CGFLOAT_MAX)];
    CGFloat height = self.titleLabel.qmui_bottom + 5 + sloganSize.height > self.qmui_height ? self.qmui_height - (self.titleLabel.qmui_bottom + 5) - 15 : sloganSize.height;
    self.sloganView.frame = CGRectMake(0, self.titleLabel.qmui_bottom + 5, self.qmui_width, height);
}

- (void)setUser:(PCUser *)user {
    _user = user;
    
    self.levelLabel.text = [NSString stringWithFormat:@"Lv.%@", @(user.level)];
    [self.avatarView pc_setImageWithURL:user.avatar ? user.avatar.imageURL : user.avatarUrl];
    [self.characterView pc_setImageWithURL:user.character placeholderImage:nil];
    self.nameLabel.text = user.name;
    self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)", user.title, [user.gender isEqualToString:@"m"] ? @"绅士" : @"淑女"];
    self.sloganView.text = user.slogan;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    
    height += 10 + [self.levelLabel sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)].height + 5 + 100 + 5 + [self.nameLabel sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)].height + 5 + [self.titleLabel sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)].height + 5 + [self.sloganView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)].height + 15;
    
    return CGSizeMake(size.width, height);
}

- (void)avatarAction:(UITapGestureRecognizer *)sender {
    UIView *superView = self.superview;
    if (superView) {
        [superView addSubview:self.previewView];
        [UIView animateWithDuration:.25 animations:^{
            self.alpha = 0;
            self.previewView.alpha = 1;
        }];
    }
}
 
#pragma mark - <QMUIZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location {
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 1;
        self.previewView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.previewView removeFromSuperview];
    }];
}

- (void)longPressInZoomingImageView:(QMUIZoomImageView *)zoomImageView {
    if (zoomImageView.image == nil) {
        return;
    }
    [UIViewController pc_actionSheetWithTitle:@"保存图片到相册" message:nil confirm:^{
        QMUIImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(zoomImageView.image, nil, ^(QMUIAsset *asset, NSError *error) {
            if (asset) {
                [QMUITips showSucceed:@"已保存到相册"];
            }
        });
    } cancel:nil];
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
        _avatarView.layer.borderColor = PCColorHotPink.CGColor;
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

- (QMUILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorBlack];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (QMUIMarqueeLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUIMarqueeLabel alloc] init];
        _titleLabel.textColor = PCColorHotPink;
        _titleLabel.font = UIFontMake(15);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (QMUITextView *)sloganView {
    if (!_sloganView) {
        _sloganView = [[QMUITextView alloc] init];
        _sloganView.font = UIFontMake(15);
        _sloganView.textColor = UIColorGray;
        _sloganView.editable = NO;
        _sloganView.textAlignment = NSTextAlignmentCenter;
        _sloganView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
    }
    return _sloganView;
}

- (QMUIZoomImageView *)previewView {
    if (!_previewView) {
        _previewView = [[QMUIZoomImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _previewView.delegate = self;
        _previewView.alpha = 0;
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.user.avatar.imageURL] options:kNilOptions progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            self->_previewView.image = [image qmui_imageResizedInLimitedSize:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH)];
        }];
    }
    return _previewView;
}

@end
