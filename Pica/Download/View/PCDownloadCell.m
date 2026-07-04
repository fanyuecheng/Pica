//
//  PCDownloadCell.m
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCDownloadCell.h"
#import "PCComicDownload.h"
#import "PCDownloadManager.h"
#import "UIImageView+PCAdd.h"
#import "PCCommonUI.h"

@interface PCDownloadCell ()

@property (nonatomic, strong) UIImageView   *coverView;
@property (nonatomic, strong) QMUILabel     *titleLabel;
@property (nonatomic, strong) QMUILabel     *authorLabel;
@property (nonatomic, strong) QMUILabel     *statusLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, copy)   NSString      *currentComicId;

@end

@implementation PCDownloadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.coverView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.authorLabel];
        [self.contentView addSubview:self.statusLabel];
        [self.contentView addSubview:self.progressView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.currentComicId = nil;
    self.coverView.image = nil;
    self.titleLabel.text = nil;
    self.authorLabel.text = nil;
    self.statusLabel.text = nil;
    self.progressView.progress = 0;
    self.progressView.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.coverView.frame = CGRectMake(15, 7.5, 60, self.contentView.qmui_height - 15);

    CGFloat leftX = CGRectGetMaxX(self.coverView.frame) + 12;
    CGFloat textWidth = self.contentView.qmui_width - leftX - 15;

    self.titleLabel.frame = CGRectMake(leftX, 10, textWidth, QMUIViewSelfSizingHeight);
    self.authorLabel.frame = CGRectMake(leftX, self.titleLabel.qmui_bottom + 4, textWidth, QMUIViewSelfSizingHeight);
    self.statusLabel.frame = CGRectMake(leftX, self.authorLabel.qmui_bottom + 6, textWidth, QMUIViewSelfSizingHeight);
    self.progressView.frame = CGRectMake(leftX, self.statusLabel.qmui_bottom + 6, textWidth, 2);
}

#pragma mark - Configure

- (void)configureWithRecord:(PCComicDownload *)record {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (!record) return;

    self.currentComicId = record.comicId;

    [self.coverView pc_setImageWithURL:record.thumbUrl];
    self.titleLabel.text = record.title.length ? record.title : @"未命名";
    self.authorLabel.text = record.author.length ? record.author : @" ";
    [self applyStateFromRecord:record];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onProgressOrStatus:) name:PCDownloadDidUpdateProgressNotification object:nil];
    [nc addObserver:self selector:@selector(onProgressOrStatus:) name:PCDownloadDidChangeStatusNotification object:nil];
    [nc addObserver:self selector:@selector(onProgressOrStatus:) name:PCDownloadDidCompleteComicNotification object:nil];
}

- (void)onProgressOrStatus:(NSNotification *)note {
    NSString *comicId = note.userInfo[PCDownloadNotificationComicIdKey];
    if (!comicId || ![comicId isEqualToString:self.currentComicId]) return;
    // 从 DB 拉最新，避免通知里 userInfo 字段不全
    PCComicDownload *record = [kPCDownloadManager recordForComicId:comicId];
    if (!record) return;
    [self applyStateFromRecord:record];
    [self setNeedsLayout];
}

- (void)applyStateFromRecord:(PCComicDownload *)record {
    self.statusLabel.text = [self statusTextForRecord:record];
    if (record.totalPictures > 0) {
        self.progressView.progress = MIN(1.0, (float)record.downloadedPictures / (float)record.totalPictures);
    } else {
        self.progressView.progress = 0;
    }
    self.progressView.hidden = (record.status != PCComicDownloadStatusDownloading &&
                                record.status != PCComicDownloadStatusQueued);

    switch (record.status) {
        case PCComicDownloadStatusFinished:
            self.statusLabel.textColor = PCColorHotPink;
            break;
        case PCComicDownloadStatusFailed:
            self.statusLabel.textColor = UIColorRed;
            break;
        case PCComicDownloadStatusPaused:
            self.statusLabel.textColor = UIColorGrayLighten;
            break;
        default:
            self.statusLabel.textColor = UIColorBlue;
            break;
    }
}

- (NSString *)statusTextForRecord:(PCComicDownload *)record {
    NSString *counter = record.totalPictures > 0
        ? [NSString stringWithFormat:@"%ld / %ld", (long)record.downloadedPictures, (long)record.totalPictures]
        : @"准备中";
    switch (record.status) {
        case PCComicDownloadStatusQueued:      return [NSString stringWithFormat:@"等待中 · %@", counter];
        case PCComicDownloadStatusDownloading: return [NSString stringWithFormat:@"下载中 · %@", counter];
        case PCComicDownloadStatusPaused:      return [NSString stringWithFormat:@"已暂停 · %@", counter];
        case PCComicDownloadStatusFinished:    return [NSString stringWithFormat:@"已完成 · %ld 张", (long)record.downloadedPictures];
        case PCComicDownloadStatusFailed:      return [NSString stringWithFormat:@"下载失败 · %@", counter];
    }
    return counter;
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
        _authorLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorGrayLighten];
    }
    return _authorLabel;
}

- (QMUILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorBlue];
    }
    return _statusLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = PCColorHotPink;
        _progressView.hidden = YES;
    }
    return _progressView;
}

@end
