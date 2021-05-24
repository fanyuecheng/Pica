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
#import "UIImage+PCAdd.h"
 
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
     
    if (category.thumb) {
        [self.imageView pc_setImageWithURL:category.thumb.imageURL];
    } else {
        CGFloat itemWidth = floorf((SCREEN_WIDTH - 40) / 3);
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        self.imageView.image = [UIImage pc_imageWithString:category.title attributes:@{NSFontAttributeName:UIFontBoldMake(18), NSForegroundColorAttributeName:UIColorMake(255, 105, 180),      NSParagraphStyleAttributeName:style} size:CGSizeMake(itemWidth, itemWidth)];
    }
    
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
