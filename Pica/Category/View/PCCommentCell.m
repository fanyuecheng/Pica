//
//  PCCommentCell.m
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCommentCell.h"
#import "PCVendorHeader.h"
#import "UIImageView+PCAdd.h"
#import "NSDate+PCAdd.h"
#import "NSString+PCAdd.h"
#import "PCCommonUI.h"
#import "PCCommentLikeRequest.h"
#import "PCUserInfoView.h"
#import "PCCommentController.h"
#import "PCCommentReportRequest.h"
#import "UIViewController+PCAdd.h"

@interface PCCommentCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *characterView;
@property (nonatomic, strong) QMUILabel   *nameLabel;
@property (nonatomic, strong) QMUILabel   *levelLabel;
@property (nonatomic, strong) QMUILabel   *titleLabel;
@property (nonatomic, strong) QMUILabel   *contentLabel;
@property (nonatomic, strong) QMUILabel   *timeLabel;
@property (nonatomic, strong) QMUIButton  *likeButton;
@property (nonatomic, strong) QMUIButton  *childButton;
@property (nonatomic, strong) QMUILabel   *topLabel;
@property (nonatomic, strong) QMUIButton  *moreButton;

@property (nonatomic, strong) PCCommentLikeRequest   *likeRequest;
@property (nonatomic, strong) PCCommentReportRequest *reportRequest;

@end

@implementation PCCommentCell
 
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.characterView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.levelLabel];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.likeButton];
        [self.contentView addSubview:self.childButton];
        [self.contentView addSubview:self.topLabel];
        [self.contentView addSubview:self.moreButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.topLabel.frame = CGRectMake(0, 0, 50, 20);
    self.avatarView.frame = CGRectMake(15, 20, 80, 80);
    self.characterView.frame = CGRectMake(5, 10, 100, 100);
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectSetXY(self.nameLabel.bounds, 110, 20);
    [self.levelLabel sizeToFit];
    self.levelLabel.frame = CGRectSetXY(self.levelLabel.bounds, 110, self.nameLabel.qmui_bottom + 20);
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectSetXY(self.titleLabel.bounds, self.levelLabel.qmui_right + 15, self.levelLabel.qmui_top + (self.levelLabel.qmui_height - self.titleLabel.qmui_height) * 0.5);
    self.contentLabel.frame = CGRectMake(110, 80, SCREEN_WIDTH - 125, QMUIViewSelfSizingHeight);
    [self.timeLabel sizeToFit];
    self.timeLabel.frame = CGRectSetXY(self.timeLabel.bounds, 15, self.qmui_height -  self.timeLabel.qmui_height - 10);
    [self.childButton sizeToFit];
    if (self.comment.isChild) {
        self.childButton.frame = CGRectMake(self.qmui_width - 10, self.qmui_height - self.childButton.qmui_height - 10, 0, 0);
    } else {
        self.childButton.frame = CGRectSetXY(self.childButton.bounds, SCREEN_WIDTH - self.childButton.qmui_width - 15, self.qmui_height - self.childButton.qmui_height - 10);
    }
    [self.likeButton sizeToFit];
    self.likeButton.frame = CGRectSetXY(self.likeButton.bounds, self.childButton.qmui_left - self.likeButton.qmui_width - 10, self.childButton.qmui_top);
    self.moreButton.frame = CGRectMake(self.qmui_width - 60, 0, 60, 40);
}

- (void)setComment:(PCComment *)comment {
    _comment = comment;
     
    [self.avatarView pc_setImageWithURL:comment.user.avatar.imageURL];
    [self.characterView pc_setImageWithURL:comment.user.character placeholderImage:nil];
    self.nameLabel.text = comment.user.name;
    self.titleLabel.text = comment.user.title;
    self.levelLabel.text = [NSString stringWithFormat:@"Lv.%@", @(comment.user.level)];
    self.contentLabel.text = [comment.content qmui_trim];
    self.timeLabel.text = [comment.created_at pc_timeString];
    [self.likeButton setTitle:[@(comment.likesCount) stringValue] forState:UIControlStateNormal];
    self.likeButton.selected = comment.isLiked;
    [self.childButton setTitle:[NSString stringWithFormat:@"子评论 %@", @(comment.commentsCount)] forState:UIControlStateNormal];
    self.topLabel.hidden = !comment.isTop;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    height += 110 + [self.contentLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 125, CGFLOAT_MAX)].height + 20;
    return CGSizeMake(SCREEN_WIDTH, height);
}

#pragma mark - Action
- (void)likeAction:(QMUIButton *)sender {
    [self.likeRequest sendRequest:^(NSNumber *isLike) {
        sender.selected = [isLike boolValue];
        [QMUITips showSucceed:[isLike boolValue] ? @"已点赞" : @"点赞取消"];
        [isLike boolValue] ? self.comment.likesCount ++ : self.comment.likesCount --;
        [sender setTitle:[@(self.comment.likesCount) stringValue] forState:UIControlStateNormal];
        [sender sizeToFit];
        sender.frame = CGRectSetX(sender.frame, self.childButton.qmui_left - self.likeButton.qmui_width - 10);
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)moreAction:(QMUIButton *)sender {
    [self report];
}
 
- (void)childAction:(QMUIButton *)sender {
    if (self.comment) {
        PCCommentController *comment = [[PCCommentController alloc] initWithCommentId:self.comment.commentId];
        comment.commentType = self.comment.game ? PCCommentTypeGame : PCCommentTypeComic;
        [[QMUIHelper visibleViewController].navigationController pushViewController:comment animated:YES];
    }
}

- (void)avatarAction:(UITapGestureRecognizer *)sender {
    if (self.comment.user) {
        QMUIModalPresentationViewController *controller = [[QMUIModalPresentationViewController alloc] init];
        PCUserInfoView *infoView = [[PCUserInfoView alloc] init];
        infoView.user = self.comment.user;
        controller.contentView = infoView;
        [controller showWithAnimated:YES completion:nil];
    }
}

#pragma mark - Method
- (void)report {
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        if (![self.reportRequest.commentId isEqualToString:self.comment.commentId]) {
            self.reportRequest.commentId = self.comment.commentId;
        }
        [self.reportRequest sendRequest:^(NSString *commentId) {
            [QMUITips showSucceed:@"举报成功"];
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }];
    
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
    
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"确认举报这个评论?" message:nil preferredStyle:QMUIAlertControllerStyleAlert];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController showWithAnimated:YES];
}

#pragma mark - Get
- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 40;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.borderWidth = .5;
        _avatarView.layer.borderColor = PCColorHotPink.CGColor;
        _avatarView.userInteractionEnabled = YES;
        [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarAction:)]];
    }
    return _avatarView;
}

- (UIImageView *)characterView {
    if (!_characterView) {
        _characterView = [[UIImageView alloc] init];
    }
    return _characterView;
}

- (QMUILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontBoldMake(14) textColor:UIColorBlack];
    }
    return _nameLabel;
}

- (QMUILabel *)levelLabel {
    if (!_levelLabel) {
        _levelLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:PCColorHotPink];
    }
    return _levelLabel;
}
 
- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(10) textColor:UIColorWhite];
        _titleLabel.backgroundColor = UIColorYellow;
        _titleLabel.layer.cornerRadius = 10;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.contentEdgeInsets = UIEdgeInsetsMake(3, 5, 3, 5);
    }
    return _titleLabel;
}
 
- (QMUILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorGrayDarken];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}
 
- (QMUILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorGray];
    }
    return _timeLabel;
}

- (QMUIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [[QMUIButton alloc] init];
        _likeButton.qmui_outsideEdge = UIEdgeInsetsMake(-10, 0, -10, 0);
        _likeButton.spacingBetweenImageAndTitle = 5;
        [_likeButton setImage:[@"🖤" pc_imageWithTextColor:UIColorWhite font:UIFontMake(12)] forState:UIControlStateNormal];
        [_likeButton setImage:[@"❤️" pc_imageWithTextColor:UIColorWhite font:UIFontMake(12)] forState:UIControlStateSelected];
        _likeButton.titleLabel.font = UIFontMake(12);
        [_likeButton setTitleColor:UIColorGray forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

- (QMUIButton *)childButton {
    if (!_childButton) {
        _childButton = [[QMUIButton alloc] init];
        _childButton.qmui_outsideEdge = UIEdgeInsetsMake(-10, 0, -10, 0);
        _childButton.titleLabel.font = UIFontMake(12);
        [_childButton setTitleColor:UIColorGray forState:UIControlStateNormal];
        [_childButton addTarget:self action:@selector(childAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _childButton;
}

- (QMUILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorWhite];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.text = @"置顶";
        _topLabel.backgroundColor = PCColorPink;
        _topLabel.layer.cornerRadius = 4;
        _topLabel.layer.masksToBounds = YES;
        _topLabel.hidden = YES;
        _topLabel.layer.maskedCorners = kCALayerMaxXMaxYCorner;
    }
    return _topLabel;
}

- (QMUIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[QMUIButton alloc] init];
        _moreButton.qmui_outsideEdge = UIEdgeInsetsMake(0, -10, -10, 0);
        _moreButton.titleLabel.font = UIFontBoldMake(18);
        [_moreButton setTitleColor:UIColorGray forState:UIControlStateNormal];
        [_moreButton setTitle:@"•••" forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (PCCommentLikeRequest *)likeRequest {
    if (!_likeRequest) {
        if (self.comment.commentId) {
            _likeRequest = [[PCCommentLikeRequest alloc] initWithCommentId:self.comment.commentId];
        }
    }
    return _likeRequest;
}

- (PCCommentReportRequest *)reportRequest {
    if (!_reportRequest) {
        _reportRequest = [[PCCommentReportRequest alloc] initWithCommentId:self.comment.commentId];
    }
    return _reportRequest;
}

@end
