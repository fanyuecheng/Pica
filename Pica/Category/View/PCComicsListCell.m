//
//  PCComicsListCell.m
//  Pica
//
//  Created by fancy on 2020/11/9.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsListCell.h"
#import "UIImageView+PCAdd.h"

@interface PCComicsListCell ()

@end
 
@implementation PCComicsListCell
 
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.coverView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.authorLabel];
        [self.contentView addSubview:self.categoryLabel];
        [self.contentView addSubview:self.likeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverView.frame = CGRectMake(15, 7.5, 90, self.contentView.qmui_height - 15);
    self.titleLabel.frame = CGRectMake(120, 7.5, self.contentView.qmui_width - 145, QMUIViewSelfSizingHeight);
    self.authorLabel.frame = CGRectMake(120, self.titleLabel.qmui_bottom + 5, self.titleLabel.qmui_width, QMUIViewSelfSizingHeight);
    self.categoryLabel.frame = CGRectMake(120, self.authorLabel.qmui_bottom + 5, self.titleLabel.qmui_width, QMUIViewSelfSizingHeight);
    self.likeLabel.frame = CGRectMake(120, self.categoryLabel.qmui_bottom + 5, self.titleLabel.qmui_width, QMUIViewSelfSizingHeight);
}

- (void)setComics:(PCComics *)comics {
    _comics = comics;
    
    [self.coverView pc_setImageWithURL:comics.thumb.imageURL];
    self.titleLabel.text = comics.title;
    self.authorLabel.text = comics.author;
    NSMutableString *category = [NSMutableString stringWithString:@"分类 "];
    [comics.categories enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [category appendFormat:@" %@", obj];
    }];
    self.categoryLabel.text = category;
    self.likeLabel.text = [NSString stringWithFormat:@"❤ %@", @(comics.likesCount)];
}

- (UIColor *)colorWithIndex:(NSInteger)index {
    UIColor *color = nil;
    switch (index) {
        case 0:
            color = UIColorMake(255, 215, 0);
            break;
        case 1:
            color = UIColorMake(255, 182, 193);
            break;
        case 2:
            color = UIColorMake(255, 105, 180);
            break;
        default:
            color = UIColorMake(128, 128, 128);
            break;
    }
    return color;
}

#pragma mark - Get
- (UIImageView *)coverView {
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.clipsToBounds = YES;
        _coverView.layer.cornerRadius = 4;
        _coverView.layer.masksToBounds = YES;
    }
    return _coverView;
}

- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontBoldMake(15) textColor:UIColorBlack];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (QMUILabel *)authorLabel {
    if (!_authorLabel) {
        _authorLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorMake(255, 105, 180)];
    }
    return _authorLabel;
}

- (QMUILabel *)categoryLabel {
    if (!_categoryLabel) {
        _categoryLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGrayLighten];
    }
    return _categoryLabel;
}

- (QMUILabel *)likeLabel {
    if (!_likeLabel) {
        _likeLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorMake(255, 105, 180)];
    }
    return _likeLabel;
}

@end
