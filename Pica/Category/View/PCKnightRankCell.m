//
//  PCKnightRankCell.m
//  Pica
//
//  Created by 米画师 on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCKnightRankCell.h"
#import "PCUser.h"
#import "UIImageView+PCAdd.h"
 
@interface PCKnightRankCell ()

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImageView *characterView;

@end

@implementation PCKnightRankCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.likeLabel.font = UIFontBoldMake(24);
        self.likeLabel.textColor = UIColorWhite;
        self.likeLabel.textAlignment = NSTextAlignmentCenter;
        self.coverView.layer.cornerRadius = 40;
        [self.contentView addSubview:self.characterView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.characterView.frame = CGRectMake(40, 5, self.qmui_height - 10, self.qmui_height - 10);
    self.likeLabel.frame = CGRectMake(0, 0, 35, self.contentView.qmui_height);
    self.coverView.frame = CGRectMake(45, 10, self.qmui_height - 20, self.qmui_height - 20);
    self.titleLabel.frame = CGRectMake(self.coverView.qmui_right + 10, 10, self.qmui_width - self.coverView.qmui_right - 10, QMUIViewSelfSizingHeight);
    self.authorLabel.frame = CGRectMake(self.titleLabel.qmui_left, self.titleLabel.qmui_bottom + 5, self.titleLabel.qmui_width, QMUIViewSelfSizingHeight);
    self.categoryLabel.frame = CGRectMake(self.titleLabel.qmui_left, self.authorLabel.qmui_bottom + 5, self.titleLabel.qmui_width, QMUIViewSelfSizingHeight);
}

#pragma mark - Set
- (void)setUser:(PCUser *)user
          index:(NSInteger)index {
    self.user = user;
    self.index = index;
}

- (void)setUser:(PCUser *)user {
    _user = user;
    
    if (user.character) {
        [self.characterView pc_setImageWithURL:user.character placeholderImage:nil];
    }
    
    [self.coverView pc_setImageWithURL:user.avatar.imageURL];
    self.titleLabel.text = user.name;
    self.authorLabel.text = [NSString stringWithFormat:@"Lv：%@    %@", @(user.level), user.title];
    self.categoryLabel.text = [NSString stringWithFormat:@"上传本子：%@", @(user.comicsUploaded)];
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    self.likeLabel.text = [@(index + 1) stringValue];
    self.likeLabel.backgroundColor = [self colorWithIndex:index];
}

- (UIImageView *)characterView {
    if (!_characterView) {
        _characterView = [[UIImageView alloc] init];
    }
    return _characterView;
}


@end
