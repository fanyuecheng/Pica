//
//  PCComicsRankCell.m
//  Pica
//
//  Created by YueCheng on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCComicsRankCell.h"
#import "PCVendorHeader.h"
#import "UIImageView+PCAdd.h"

@interface PCComicsRankCell ()

@property (nonatomic, strong) QMUILabel *numberLabel;
@property (nonatomic, assign) NSInteger index;

@end

@implementation PCComicsRankCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.likeLabel.font = UIFontBoldMake(24);
        [self.contentView addSubview:self.numberLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.numberLabel.frame = CGRectMake(0, 0, 35, self.contentView.qmui_height);
    self.coverView.frame = CGRectMake(45, 10, 100, self.qmui_height - 20);
    self.titleLabel.frame = CGRectMake(155, 10, self.qmui_width - 160, QMUIViewSelfSizingHeight);
    self.authorLabel.frame = CGRectMake(155, self.titleLabel.qmui_bottom + 5, self.titleLabel.qmui_width, QMUIViewSelfSizingHeight);
    self.categoryLabel.frame = CGRectMake(155, self.authorLabel.qmui_bottom + 5, self.titleLabel.qmui_width, QMUIViewSelfSizingHeight);
    self.likeLabel.frame = CGRectMake(155, self.categoryLabel.qmui_bottom + 5, self.titleLabel.qmui_width, QMUIViewSelfSizingHeight);
}

- (void)setComics:(PCComics *)comics
            index:(NSInteger)index {
    self.comics = comics;
    self.index = index;
}

#pragma mark - Method


#pragma mark - Set
- (void)setComics:(PCComics *)comics {
    [super setComics:comics];
    
    self.likeLabel.text = [@(comics.leaderboardCount) stringValue];
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    self.numberLabel.text = [@(index + 1) stringValue];
    self.numberLabel.backgroundColor = [self colorWithIndex:index];
    self.likeLabel.textColor = [self colorWithIndex:index];
}

#pragma mark - Get
- (QMUILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontBoldMake(24) textColor:UIColorWhite];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _numberLabel;
}

@end
