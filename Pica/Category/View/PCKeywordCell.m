//
//  PCKeywordCell.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCKeywordCell.h"
#import <QMUIKit/QMUIKit.h>

@interface PCKeywordCell ()

@property (nonatomic, strong) QMUILabel *titleLabel;

@end

@implementation PCKeywordCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) { 
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = self.contentView.bounds;
}

 

#pragma mark - Set
- (void)setKeyword:(NSString *)keyword {
    _keyword = [keyword copy];
    self.titleLabel.text = keyword;
}

#pragma mark - Get
- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorWhite];
        _titleLabel.layer.cornerRadius = 13;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = UIColorBlue;
    }
    return _titleLabel;
}

@end
