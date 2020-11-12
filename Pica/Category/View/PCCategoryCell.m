//
//  PCCategoryCell.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCategoryCell.h"
#import "PCVendorHeader.h"
#import "UIImageView+PCAdd.h"
 
@interface PCCategoryCell ()

@property (nonatomic, strong) SDAnimatedImageView *imageView;
@property (nonatomic, strong) QMUILabel           *titleLabel;

@end

@implementation PCCategoryCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, self.contentView.qmui_width, self.contentView.qmui_width);
    self.titleLabel.frame = CGRectMake(0, self.contentView.qmui_width, self.contentView.qmui_width, 20);
}

#pragma mark - Set
- (void)setCategory:(PCCategory *)category {
    _category = category;
     
    [self.imageView pc_setImageWithURL:category.thumb.imageURL];
    self.titleLabel.text = category.title;
}

#pragma mark - Get
- (SDAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[SDAnimatedImageView alloc] init];
        _imageView.layer.cornerRadius = 4;
        _imageView.layer.masksToBounds = YES;
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

@end
