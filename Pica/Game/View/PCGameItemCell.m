//
//  PCGameItemCell.m
//  Pica
//
//  Created by Fancy on 2021/6/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCGameItemCell.h"
#import "UIImageView+PCAdd.h"

@implementation PCGameItemCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, self.contentView.qmui_width, self.contentView.qmui_width);
    self.iconLabel.frame = CGRectMake(0, self.imageView.qmui_bottom, self.contentView.qmui_width, 20);
    self.titleLabel.frame = CGRectMake(0, self.iconLabel.qmui_bottom, self.contentView.qmui_width, 20);
}

#pragma mark - Set
- (void)setGame:(PCGame *)game {
    _game = game;
    
    [self.imageView pc_setImageWithURL:game.icon.imageURL];
    self.titleLabel.text = game.title;
    self.iconLabel.text = game.publisher;
}

#pragma mark - Get
- (QMUILabel *)iconLabel {
    QMUILabel *iconLabel= [super iconLabel];
    iconLabel.font = UIFontMake(12);
    iconLabel.textColor = UIColorGray;
    return iconLabel;
}

@end
