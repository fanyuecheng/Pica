//
//  PCComicsInfoView.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsInfoView.h"
#import "PCVendorHeader.h"
#import "UIImageView+PCAdd.h"
#import "UIImage+PCAdd.h"
#import "NSDate+PCAdd.h"
#import "PCLikeRequest.h"
#import "PCComicsFavouriteRequest.h"
#import "PCComicsListController.h"
#import "PCCommentController.h"
#import "PCUserInfoView.h"
#import "PCCommonUI.h"

@interface PCComicsInfoView ()

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) QMUILabel   *titleLabel;
@property (nonatomic, strong) QMUILabel   *authorLabel;
@property (nonatomic, strong) QMUILabel   *sinicizationLabel;
@property (nonatomic, strong) QMUILabel   *viewLabel;
@property (nonatomic, strong) QMUILabel   *categoryLabel;
@property (nonatomic, strong) QMUILabel   *descLabel;
@property (nonatomic, strong) QMUIButton  *commentButton;
@property (nonatomic, strong) QMUIButton  *likeButton;
@property (nonatomic, strong) QMUIButton  *favouriteButton;
@property (nonatomic, strong) QMUIFloatLayoutView *tagView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) QMUILabel   *nameLabel;
@property (nonatomic, strong) QMUILabel   *timeLabel;

@end

@implementation PCComicsInfoView

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
    [self addSubview:self.coverView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.authorLabel];
    [self addSubview:self.sinicizationLabel];
    [self addSubview:self.viewLabel];
    [self addSubview:self.categoryLabel];
    [self addSubview:self.descLabel];
    [self addSubview:self.commentButton];
    [self addSubview:self.likeButton];
    [self addSubview:self.favouriteButton];
    [self addSubview:self.tagView];
    [self addSubview:self.avatarView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.timeLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        return;
    }
    
    self.coverView.frame = CGRectMake(15, 10, 90, 130);
    self.titleLabel.frame = CGRectMake(115, 10, self.qmui_width - 120, QMUIViewSelfSizingHeight);
    self.authorLabel.frame = CGRectMake(115, self.titleLabel.qmui_bottom + 5, self.qmui_width - 120, QMUIViewSelfSizingHeight);
    self.sinicizationLabel.frame = CGRectMake(115, self.authorLabel.qmui_bottom + 5, self.qmui_width - 120, QMUIViewSelfSizingHeight);
    self.viewLabel.frame = CGRectMake(115, self.sinicizationLabel.qmui_bottom + 5, self.qmui_width - 120, QMUIViewSelfSizingHeight);
    self.categoryLabel.frame = CGRectMake(115, self.viewLabel.qmui_bottom + 5, self.qmui_width - 120, QMUIViewSelfSizingHeight);
    self.tagView.frame = CGRectMake(15, self.coverView.qmui_bottom + 10, self.qmui_width - 30, QMUIViewSelfSizingHeight);
    self.descLabel.frame = CGRectMake(15, self.comics.tags.count ? self.tagView.qmui_bottom + 10 : self.tagView.qmui_bottom, self.qmui_width - 30, QMUIViewSelfSizingHeight);
    CGFloat buttonWidth = floorf(self.qmui_width / 3);
    self.commentButton.frame = CGRectMake(0, self.descLabel.qmui_bottom + 10, buttonWidth, 50);
    self.likeButton.frame = CGRectMake(buttonWidth * 1, self.descLabel.qmui_bottom + 10, buttonWidth, 50);
    self.favouriteButton.frame = CGRectMake(buttonWidth * 2, self.descLabel.qmui_bottom + 10, buttonWidth, 50);
    self.avatarView.frame = CGRectMake(15, self.commentButton.qmui_bottom, 50, 50);
    self.nameLabel.frame = CGRectMake(75, self.avatarView.qmui_top + 5, self.qmui_width - 90, QMUIViewSelfSizingHeight);
    self.timeLabel.frame = CGRectMake(75, self.nameLabel.qmui_bottom + 5, self.qmui_width - 90, QMUIViewSelfSizingHeight); 
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    height += 10 + 130;
    if (self.comics.tags.count) {
        height += 10 + [self.tagView sizeThatFits:CGSizeMake(SCREEN_WIDTH - 30, CGFLOAT_MAX)].height + 10;
    } else {
        height += 10;
    }
    height += [self.descLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 30, CGFLOAT_MAX)].height + 10 + 50 + 50; 
    
    return CGSizeMake(SCREEN_WIDTH, height);
}

#pragma mark - Action
- (void)buttonAction:(QMUIButton *)sender {
    switch (sender.tag) {
        case 1000:
            [self commentAction];
            break;
        case 1001:
            [self likeAction];
            break;
        case 1002:
            [self favouriteAction];
            break;
        default:
            break;
    }
}

- (void)tagAction:(QMUIButton *)sender {
    PCComicsListController *list = [[PCComicsListController alloc] initWithType:PCComicsListTypeSearch];
    list.keyword = sender.currentTitle;
    [[QMUIHelper visibleViewController].navigationController pushViewController:list animated:YES];
}

- (void)avatarAction:(UIGestureRecognizer *)sender {
    QMUIModalPresentationViewController *controller = [[QMUIModalPresentationViewController alloc] init];
    PCUserInfoView *infoView = [[PCUserInfoView alloc] init];
    infoView.user = self.comics.creator;
    controller.contentView = infoView;
    [controller showWithAnimated:YES completion:nil];
}

- (void)commentAction {
    PCCommentController *comment = [[PCCommentController alloc] initWithComicsId:self.comics.comicsId];
    comment.commentType = PCCommentTypeComic;
    [[QMUIHelper visibleViewController].navigationController pushViewController:comment animated:YES];
}

#pragma mark - Net
- (void)likeAction {
    PCLikeRequest *request = [[PCLikeRequest alloc] initWithComicsId:self.comics.comicsId];
    [request sendRequest:^(NSNumber *liked) {
        self.likeButton.selected = [liked boolValue];
        [liked boolValue] ? self.likeButton.qmui_badgeInteger ++ : self.likeButton.qmui_badgeInteger --;
    } failure:^(NSError * _Nonnull error) {
        [QMUITips showError:error.localizedDescription];
    }];
}

- (void)favouriteAction {
    PCComicsFavouriteRequest *request = [[PCComicsFavouriteRequest alloc] initWithComicsId:self.comics.comicsId];
    [request sendRequest:^(NSNumber *favourite) {
        self.favouriteButton.selected = [favourite boolValue];
    } failure:^(NSError * _Nonnull error) {
        [QMUITips showError:error.localizedDescription];
    }];
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
        _titleLabel = [[QMUILabel alloc] init];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (QMUILabel *)authorLabel {
    if (!_authorLabel) {
        _authorLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:PCColorHotPink];
    }
    return _authorLabel;
}

- (QMUILabel *)sinicizationLabel {
    if (!_sinicizationLabel) {
        _sinicizationLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGrayLighten];
    }
    return _sinicizationLabel;
}

- (QMUILabel *)categoryLabel {
    if (!_categoryLabel) {
        _categoryLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGrayLighten];
    }
    return _categoryLabel;
}

- (QMUILabel *)viewLabel {
    if (!_viewLabel) {
        _viewLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGrayLighten];
    }
    return _viewLabel;
}

- (QMUIFloatLayoutView *)tagView {
    if (!_tagView) {
        _tagView = [[QMUIFloatLayoutView alloc] init];
        _tagView.itemMargins = UIEdgeInsetsMake(0, 0, 10, 10);
    }
    return _tagView;
}

- (QMUILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGray];
        _descLabel.numberOfLines = 0;
    }
    return _descLabel;
}

- (QMUIButton *)buttonWithTag:(NSInteger)tag {
    QMUIButton *button = [[QMUIButton alloc] init];
    button.tag = tag;
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (QMUIButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [self buttonWithTag:1000];
        [_commentButton setImage:[UIImage pc_iconWithText:ICON_COMMENT size:20 color:UIColorBlue] forState:UIControlStateNormal];
        CGFloat buttonWidth = floorf(SCREEN_WIDTH / 3);
        _commentButton.qmui_badgeOffset = CGPointMake(10 - buttonWidth * 0.5, 20);
    }
    return _commentButton;
}

- (QMUIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [self buttonWithTag:1001];
        [_likeButton setImage:[UIImage pc_iconWithText:ICON_GOOD size:20 color:UIColorGray] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage pc_iconWithText:ICON_GOOD size:20 color:UIColorBlue] forState:UIControlStateSelected];
        CGFloat buttonWidth = floorf(SCREEN_WIDTH / 3);
        _likeButton.qmui_badgeOffset = CGPointMake(10 - buttonWidth * 0.5, 20);
    }
    return _likeButton;
}

- (QMUIButton *)favouriteButton {
    if (!_favouriteButton) {
        _favouriteButton = [self buttonWithTag:1002];
        [_favouriteButton setImage:[UIImage pc_iconWithText:ICON_FAVORITE size:20 color:UIColorGray] forState:UIControlStateNormal];
        [_favouriteButton setImage:[UIImage pc_iconWithText:ICON_FAVORITE size:20 color:UIColorBlue] forState:UIControlStateSelected];
    }
    return _favouriteButton;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = 25;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.userInteractionEnabled = YES;
        [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarAction:)]];
    }
    return _avatarView;
}

- (QMUILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(16) textColor:UIColorGrayDarken];
    }
    return _nameLabel;
}

- (QMUILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGray];
    }
    return _timeLabel;
}

#pragma mark - Set
- (void)setComics:(PCComics *)comics {
    _comics = comics;
    
    [self.coverView pc_setImageWithURL:comics.thumb.imageURL];
    self.titleLabel.text = comics.title;
    self.authorLabel.text = comics.author;
    self.sinicizationLabel.text = comics.chineseTeam;
    self.viewLabel.text = [NSString stringWithFormat:@"绅士指名次数：%@ %@", @(comics.viewsCount), comics.finished ? @"(已完结)" : @""];
    NSMutableString *category = [NSMutableString stringWithString:@"分类 "];
    [comics.categories enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [category appendFormat:@" %@", obj];
    }];
    self.categoryLabel.text = category;
    self.descLabel.text = comics.desc;
    [self.tagView qmui_removeAllSubviews];
    
    [comics.tags enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        QMUIFillButton *button = [[QMUIFillButton alloc] initWithFillType:QMUIFillButtonColorBlue];
        button.titleLabel.font = UIFontBoldMake(13);
        [button setTitle:obj forState:UIControlStateNormal];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 12, 10);
        [button addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.tagView addSubview:button];
    }];
    
    self.likeButton.selected = comics.isLiked;
    self.likeButton.qmui_badgeInteger = comics.likesCount;
    
    self.favouriteButton.selected = comics.isFavourite;
    self.commentButton.qmui_badgeInteger = comics.commentsCount;
    
    [self.avatarView pc_setImageWithURL:comics.creator.avatar.imageURL];
    self.nameLabel.text = comics.creator.name;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ 更新", [comics.updated_at pc_timeInfo]];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
