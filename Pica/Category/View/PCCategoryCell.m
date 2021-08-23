//
//  PCCategoryCell.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCategoryCell.h"
#import "UIImageView+PCAdd.h"
#import "UIImage+PCAdd.h"
#import "PCCommonUI.h"

@interface PCCategoryCell ()

@end

@implementation PCCategoryCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView sd_cancelCurrentImageLoad];
    self.imageView.image = nil;
    self.titleLabel.text = nil;
    self.iconLabel.text = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.iconLabel];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, self.contentView.qmui_width, self.contentView.qmui_width);
    self.iconLabel.frame = CGRectMake(0, 0, self.contentView.qmui_width, self.contentView.qmui_width);
    self.titleLabel.frame = CGRectMake(0, self.contentView.qmui_width, self.contentView.qmui_width, 20);
}

#pragma mark - Set
- (void)setCategory:(PCCategory *)category {
    _category = category;
     
    if (category.thumb) {
        self.iconLabel.text = nil;
        [self.imageView pc_setImageWithURL:category.thumb.imageURL];
    } else {
        self.iconLabel.text = category.desc;
        self.imageView.image = nil;
    }
    
    self.titleLabel.text = category.title;
}

#pragma mark - Get
- (SDAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[SDAnimatedImageView alloc] init];
        _imageView.layer.cornerRadius = 4;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.borderWidth = .5;
        _imageView.layer.borderColor = UIColorSeparator.CGColor;
    }
    return _imageView;
}

- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorBlack];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (QMUILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [[QMUILabel alloc] qmui_initWithFont:[UIFont fontWithName:@"iconfont" size:45] textColor:PCColorPink];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _iconLabel;
}

@end
