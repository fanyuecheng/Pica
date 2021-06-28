//
//  PCGameInfoView.m
//  Pica
//
//  Created by Fancy on 2021/6/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCGameInfoView.h"
#import "PCVendorHeader.h"
#import "UIImageView+PCAdd.h"
#import "UIImage+PCAdd.h"
#import "PCCommonUI.h"
#import "PCDefineHeader.h"
#import "PCGame.h"
#import "PCThumb.h"
#import "PCCommentController.h"
#import "PCLikeRequest.h"
#import <SafariServices/SafariServices.h>
#import <AVKit/AVKit.h>

@interface PCGameInfoView () <UICollectionViewDelegate, UICollectionViewDataSource, QMUIImagePreviewViewDelegate>

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) QMUILabel   *playLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) QMUILabel   *titleLabel;
@property (nonatomic, strong) QMUIFloatLayoutView *floatLayoutView;
@property (nonatomic, strong) QMUILabel   *publisherLabel;
@property (nonatomic, strong) QMUILabel   *sizeLabel;
@property (nonatomic, strong) QMUIButton  *downloadButton;
@property (nonatomic, strong) QMUIButton  *commentButton;
@property (nonatomic, strong) QMUIButton  *likeButton;
@property (nonatomic, strong) UICollectionView *screenshotsView;

@property (nonatomic, strong) QMUIImagePreviewViewController *previewViewController;
 
@end

@implementation PCGameInfoView

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
    [self addSubview:self.playLabel];
    [self addSubview:self.iconView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.floatLayoutView];
    [self addSubview:self.publisherLabel];
    [self addSubview:self.sizeLabel];
    [self addSubview:self.commentButton];
    [self addSubview:self.likeButton];
    [self addSubview:self.downloadButton];
    [self addSubview:self.screenshotsView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        return;
    }
    
    self.coverView.frame = CGRectMake(0, 0, self.qmui_width, self.qmui_width / 16 * 9);
    self.playLabel.frame = self.coverView.frame;
    self.iconView.frame = CGRectMake(10, self.coverView.qmui_bottom + 10, 100, 100);
    self.titleLabel.frame = CGRectMake(120, self.iconView.qmui_top, self.qmui_width - 130, QMUIViewSelfSizingHeight);
    self.floatLayoutView.frame = CGRectMake(120, self.titleLabel.qmui_bottom + 5, self.qmui_width - 130, 50);
    self.publisherLabel.frame = CGRectMake(120, self.floatLayoutView.qmui_bottom + 5, self.qmui_width - 130, QMUIViewSelfSizingHeight);
    self.sizeLabel.frame = CGRectMake(120, self.publisherLabel.qmui_bottom + 5, self.qmui_width - 130, QMUIViewSelfSizingHeight);
    CGFloat buttonWidth = floorf(SCREEN_WIDTH / 3);
    self.downloadButton.frame = CGRectMake(0, self.sizeLabel.qmui_bottom + 10, buttonWidth, 44);
    self.commentButton.frame = CGRectMake(self.downloadButton.qmui_right, self.downloadButton.qmui_top, buttonWidth, 44);
    self.likeButton.frame = CGRectMake(self.commentButton.qmui_right, self.downloadButton.qmui_top, buttonWidth, 44);
    self.screenshotsView.frame = CGRectMake(0, self.downloadButton.qmui_bottom + 10, self.qmui_width, self.qmui_width / 16 * 9);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    height += SCREEN_WIDTH / 16 * 9 + 10 + [self.titleLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 130, CGFLOAT_MAX)].height + 5 + 50 + 5 + [self.publisherLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 130, CGFLOAT_MAX)].height + 5 + [self.sizeLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 130, CGFLOAT_MAX)].height + 5 + 10 + 44 + 10 + SCREEN_WIDTH / 16 * 9 + 10;
    return CGSizeMake(SCREEN_WIDTH, height);
}

#pragma mark - Action
- (void)buttonAction:(QMUIButton *)sender {
    switch (sender.tag) {
        case 1000:
            [self downloadAction];
            break;
        case 1001:
            [self commentAction];
            break;
        case 1002:
            [self likeAction];
            break;
        default:
            break;
    }
}

- (void)downloadAction {
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:self.game.iosLinks.firstObject]];
    [[QMUIHelper visibleViewController] presentViewController:safari animated:YES completion:nil];
}

- (void)commentAction {
    PCCommentController *comment = [[PCCommentController alloc] initWithGameId:self.game.gameId];
    comment.commentType = PCCommentTypeGame;
    [[QMUIHelper visibleViewController].navigationController pushViewController:comment animated:YES];
}

- (void)likeAction {
    PCLikeRequest *request = [[PCLikeRequest alloc] initWithGameId:self.game.gameId];
    [request sendRequest:^(NSNumber *liked) {
        self.likeButton.selected = [liked boolValue];
        [liked boolValue] ? self.likeButton.qmui_badgeInteger ++ : self.likeButton.qmui_badgeInteger --;
    } failure:^(NSError * _Nonnull error) {
        [QMUITips showError:error.localizedDescription];
    }];
}

- (void)playAction:(UITapGestureRecognizer *)sender {
    NSURL *videoUrl = [NSURL URLWithString:self.game.videoLink];
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:videoUrl];
    AVPlayerViewController *playerController =[[AVPlayerViewController alloc] init];
    playerController.player = player;
    [[QMUIHelper visibleViewController] presentViewController:playerController animated:YES completion:nil];
}

#pragma mark - Set
- (void)setGame:(PCGame *)game {
    _game = game;
    [self.coverView pc_setImageWithURL:game.screenshots.firstObject.imageURL];
    self.playLabel.hidden = game.videoLink.length == 0;
    [self.iconView pc_setImageWithURL:game.icon.imageURL];
    self.titleLabel.text = game.title;
    [self.floatLayoutView qmui_removeAllSubviews];
    
    if (game.suggest) {
        [self.floatLayoutView addSubview:[self badgeLabelWithText:ICON_GOOD icon:YES]];
    }
    if (game.adult) {
        [self.floatLayoutView addSubview:[self badgeLabelWithText:@"R18" icon:NO]];
    }
    if (game.ios) {
        [self.floatLayoutView addSubview:[self badgeLabelWithText:ICON_IOS icon:YES]];
    }
    if (game.android) {
        [self.floatLayoutView addSubview:[self badgeLabelWithText:ICON_ANDROID icon:YES]];
    }
    self.publisherLabel.text = game.publisher;
    CGFloat size = game.iosSize ? game.iosSize : game.androidSize;
    self.sizeLabel.text = [NSString stringWithFormat:@"%@M %@下载", @(size), @(game.downloadsCount)];
    [self.screenshotsView reloadData];
    self.likeButton.selected = game.isLiked;
    self.likeButton.qmui_badgeInteger = game.likesCount;
    self.commentButton.qmui_badgeInteger = game.commentsCount;
}

- (QMUILabel *)badgeLabelWithText:(NSString *)text
                             icon:(BOOL)icon {
    QMUILabel *label = [[QMUILabel alloc] qmui_initWithFont:icon ? [UIFont fontWithName:@"iconfont" size:20] : UIFontBoldMake(20) textColor:PCColorPink];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    return label;
}

#pragma mark - Get
- (UIImageView *)coverView {
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.clipsToBounds = YES;
    }
    return _coverView;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
    }
    return _iconView;
}

- (QMUILabel *)playLabel {
    if (!_playLabel) {
        _playLabel = [[QMUILabel alloc] qmui_initWithFont:[UIFont fontWithName:@"iconfont" size:100] textColor:UIColorBlack];
        _playLabel.textAlignment = NSTextAlignmentCenter;
        _playLabel.text = ICON_PLAY;
        _playLabel.userInteractionEnabled = YES;
        [_playLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAction:)]];
    }
    return _playLabel;
}

- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorBlack];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (QMUIFloatLayoutView *)floatLayoutView {
    if (!_floatLayoutView) {
        _floatLayoutView = [[QMUIFloatLayoutView alloc] init];
        _floatLayoutView.minimumItemSize = CGSizeMake(50, 50);
    }
    return _floatLayoutView;
}

- (QMUILabel *)publisherLabel {
    if (!_publisherLabel) {
        _publisherLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGray];
        _publisherLabel.numberOfLines = 0;
    }
    return _publisherLabel;
}

- (QMUILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGray];
        _sizeLabel.numberOfLines = 0;
    }
    return _sizeLabel;
}

- (QMUIButton *)buttonWithTag:(NSInteger)tag {
    QMUIButton *button = [[QMUIButton alloc] init];
    button.tag = tag;
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (QMUIButton *)downloadButton {
    if (!_downloadButton) {
        _downloadButton = [self buttonWithTag:1000];
        [_downloadButton setImage:[UIImage pc_iconWithText:ICON_DOWNLOAD size:30 color:UIColorBlue] forState:UIControlStateNormal];
    }
    return _downloadButton;
}

- (QMUIButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [self buttonWithTag:1001];
        [_commentButton setImage:[UIImage pc_iconWithText:ICON_COMMENT size:30 color:UIColorBlue] forState:UIControlStateNormal];
        CGFloat buttonWidth = floorf(SCREEN_WIDTH / 3);
        _commentButton.qmui_badgeOffset = CGPointMake(10 - buttonWidth * 0.5, 20);
    }
    return _commentButton;
}

- (QMUIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [self buttonWithTag:1002];
        [_likeButton setImage:[UIImage pc_iconWithText:ICON_HEART size:30 color:UIColorGray] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage pc_iconWithText:ICON_HEART size:30 color:UIColorBlue] forState:UIControlStateSelected];
        CGFloat buttonWidth = floorf(SCREEN_WIDTH / 3);
        _likeButton.qmui_badgeOffset = CGPointMake(10 - buttonWidth * 0.5, 20);
    }
    return _likeButton;
}

- (UICollectionView *)screenshotsView {
    if (!_screenshotsView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(SCREEN_WIDTH, floor(SCREEN_WIDTH / 16 * 9));
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
 
        _screenshotsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _screenshotsView.backgroundColor = UIColorWhite;
        _screenshotsView.delegate = self;
        _screenshotsView.dataSource = self;
        _screenshotsView.pagingEnabled = YES;
        [_screenshotsView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        if (@available(iOS 11, *)) {
            _screenshotsView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _screenshotsView;
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.game.screenshots.count ? self.game.screenshots.count - 1 : 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    UIImageView *imageView = [cell.contentView viewWithTag:1000];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = 1000;
        [cell.contentView addSubview:imageView];
    }
    
    [imageView pc_setImageWithURL:self.game.screenshots[indexPath.row + 1].imageURL];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (!self.previewViewController) {
        self.previewViewController = [[QMUIImagePreviewViewController alloc] init];
        self.previewViewController.presentingStyle = QMUIImagePreviewViewControllerTransitioningStyleZoom;
        self.previewViewController.imagePreviewView.delegate = self;
    }
    self.previewViewController.imagePreviewView.currentImageIndex = indexPath.item;
    
    self.previewViewController.sourceImageView = ^UIView *{
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        return [cell.contentView viewWithTag:1000];
    };
    
    [[QMUIHelper visibleViewController] presentViewController:self.previewViewController animated:YES completion:nil];
}

#pragma mark - QMUIImagePreviewViewDelegate
- (NSUInteger)numberOfImagesInImagePreviewView:(QMUIImagePreviewView *)imagePreviewView {
    return self.game.screenshots.count - 1;
}

- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView renderZoomImageView:(QMUIZoomImageView *)zoomImageView atIndex:(NSUInteger)index {
    PCThumb *screenshot = self.game.screenshots[index + 1];
    zoomImageView.reusedIdentifier = @(index);
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:screenshot.imageURL]
                                                options:kNilOptions
                                               progress:nil
                                              completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            zoomImageView.image = image;
        }
    }];
}

- (QMUIImagePreviewMediaType)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index {
    return QMUIImagePreviewMediaTypeImage;
}

- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView willScrollHalfToIndex:(NSUInteger)index {
    [self.screenshotsView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
}

#pragma mark - <QMUIZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location {
    // 退出图片预览
    [[QMUIHelper visibleViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
