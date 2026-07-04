//
//  PCComicDownloadDetailController.m
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCComicDownloadDetailController.h"
#import "PCDownloadManager.h"
#import "PCDownloadPath.h"
#import "PCComicDownload.h"
#import "PCComicDownloadEpisode.h"
#import "PCComicPictureController.h"
#import "PCEpisode.h"
#import "UIImageView+PCAdd.h"
#import "PCCommonUI.h"
#import "PCVendorHeader.h"

@interface PCComicDownloadDetailController ()

@property (nonatomic, copy)   NSString *comicId;
@property (nonatomic, strong) PCComicDownload *record;
@property (nonatomic, strong) NSArray<PCComicDownloadEpisode *> *episodes;

// header 视图
@property (nonatomic, strong) UIImageView    *coverView;
@property (nonatomic, strong) QMUILabel      *titleLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) QMUILabel      *progressLabel;

@property (nonatomic, assign) BOOL reloadScheduled;

@end

@implementation PCComicDownloadDetailController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithComicId:(NSString *)comicId {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _comicId = [comicId copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(scheduleReload:) name:PCDownloadDidUpdateProgressNotification object:nil];
    [nc addObserver:self selector:@selector(scheduleReload:) name:PCDownloadDidChangeStatusNotification object:nil];
    [nc addObserver:self selector:@selector(scheduleReload:) name:PCDownloadDidCompleteComicNotification object:nil];
    [nc addObserver:self selector:@selector(scheduleReload:) name:PCDownloadDidDeleteComicNotification object:nil];

    [self reloadData];
}

/// 节流：多张图片同时完成时，300ms 内只 reload 一次
- (void)scheduleReload:(NSNotification *)note {
    NSString *comicId = note.userInfo[PCDownloadNotificationComicIdKey];
    if (comicId.length && ![comicId isEqualToString:self.comicId]) return;
    if (self.reloadScheduled) return;
    self.reloadScheduled = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.reloadScheduled = NO;
        [self reloadData];
    });
}

- (void)setupNavigationItems {
    [super setupNavigationItems];

    self.title = self.record.title ?: @"下载详情";

    PCComicDownload *r = self.record;
    if (!r) return;

    NSMutableArray *items = [NSMutableArray array];
    if (r.status == PCComicDownloadStatusDownloading || r.status == PCComicDownloadStatusQueued) {
        [items addObject:[UIBarButtonItem qmui_itemWithTitle:@"暂停" target:self action:@selector(pauseAction:)]];
    } else if (r.status == PCComicDownloadStatusPaused) {
        [items addObject:[UIBarButtonItem qmui_itemWithTitle:@"继续" target:self action:@selector(resumeAction:)]];
    } else if (r.status == PCComicDownloadStatusFailed) {
        [items addObject:[UIBarButtonItem qmui_itemWithTitle:@"重试" target:self action:@selector(retryAction:)]];
    }
    [items addObject:[UIBarButtonItem qmui_itemWithTitle:@"删除" target:self action:@selector(deleteAction:)]];
    self.navigationItem.rightBarButtonItems = items;
}

- (void)initTableView {
    [super initTableView];

    [self.tableView registerClass:[QMUITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableHeaderView = [self headerView];
}

- (UIView *)headerView {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    header.backgroundColor = UIColorWhite;

    _coverView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 90, 120)];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    _coverView.clipsToBounds = YES;
    _coverView.layer.cornerRadius = 4;
    _coverView.layer.masksToBounds = YES;
    [header addSubview:_coverView];

    CGFloat leftX = CGRectGetMaxX(_coverView.frame) + 12;
    CGFloat textW = SCREEN_WIDTH - leftX - 15;

    _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontBoldMake(16) textColor:UIColorBlack];
    _titleLabel.frame = CGRectMake(leftX, 18, textW, QMUIViewSelfSizingHeight);
    [header addSubview:_titleLabel];

    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(leftX, 70, textW, 2)];
    _progressView.progressTintColor = PCColorHotPink;
    [header addSubview:_progressView];

    _progressLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGray];
    _progressLabel.frame = CGRectMake(leftX, 78, textW, 20);
    [header addSubview:_progressLabel];

    return header;
}

#pragma mark - Data

- (void)reloadData {
    self.record = [kPCDownloadManager recordForComicId:self.comicId];
    if (!self.record) {
        // 记录被删了，pop
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    self.episodes = (NSArray<PCComicDownloadEpisode *> *)[PCComicDownloadEpisode
        objectsWhere:@"WHERE comicId = ? ORDER BY episodeOrder ASC"
        arguments:@[self.comicId]];

    [self updateHeader];
    [self setupNavigationItems];
    [self.tableView reloadData];
}

- (void)updateHeader {
    [self.coverView pc_setImageWithURL:self.record.thumbUrl];
    self.titleLabel.text = self.record.title;
    if (self.record.totalPictures > 0) {
        self.progressView.progress = MIN(1.0, (float)self.record.downloadedPictures / (float)self.record.totalPictures);
        self.progressLabel.text = [NSString stringWithFormat:@"%ld / %ld 张 · %@",
                                    (long)self.record.downloadedPictures,
                                    (long)self.record.totalPictures,
                                    [self statusTextForStatus:self.record.status]];
    } else {
        self.progressView.progress = 0;
        self.progressLabel.text = [self statusTextForStatus:self.record.status];
    }
}

#pragma mark - Actions

- (void)pauseAction:(id)sender {
    [kPCDownloadManager pauseComicId:self.comicId];
}

- (void)resumeAction:(id)sender {
    [kPCDownloadManager resumeComicId:self.comicId];
}

- (void)retryAction:(id)sender {
    [kPCDownloadManager retryComicId:self.comicId];
}

- (void)deleteAction:(id)sender {
    QMUIAlertAction *confirm = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDestructive handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        [kPCDownloadManager deleteComicId:self.comicId];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    QMUIAlertAction *cancel = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
    QMUIAlertController *alert = [QMUIAlertController alertControllerWithTitle:@"确认删除?"
                                                                        message:@"该本漫画的下载文件将全部清除"
                                                                 preferredStyle:QMUIAlertControllerStyleAlert];
    [alert addAction:confirm];
    [alert addAction:cancel];
    [alert showWithAnimated:YES];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.episodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    PCComicDownloadEpisode *ep = self.episodes[indexPath.row];
    cell.textLabel.text = ep.title.length ? ep.title : [NSString stringWithFormat:@"第 %ld 话", (long)ep.episodeOrder];

    NSString *detail = nil;
    if (ep.totalPages > 0) {
        detail = [NSString stringWithFormat:@"%ld / %ld", (long)ep.downloadedPages, (long)ep.totalPages];
    } else {
        detail = @"—";
    }
    switch (ep.status) {
        case PCComicDownloadStatusFinished:
            cell.detailTextLabel.text = detail;
            cell.textLabel.textColor = UIColorBlack;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case PCComicDownloadStatusDownloading:
        case PCComicDownloadStatusQueued:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"下载中 · %@", detail];
            cell.textLabel.textColor = UIColorBlue;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case PCComicDownloadStatusFailed:
            cell.detailTextLabel.text = @"下载失败";
            cell.textLabel.textColor = UIColorRed;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case PCComicDownloadStatusPaused:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"已暂停 · %@", detail];
            cell.textLabel.textColor = UIColorGrayLighten;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        default:
            cell.detailTextLabel.text = detail;
            cell.textLabel.textColor = UIColorBlack;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PCComicDownloadEpisode *ep = self.episodes[indexPath.row];
    if (ep.status != PCComicDownloadStatusFinished) return;

    // 构造 PCEpisode 数组用于阅读器
    NSMutableArray<PCEpisode *> *episodes = [NSMutableArray array];
    for (PCComicDownloadEpisode *de in self.episodes) {
        PCEpisode *e = [[PCEpisode alloc] init];
        e.episodeId = de.episodeUid;
        e.title = de.title;
        e.order = (int32_t)de.episodeOrder;
        [episodes addObject:e];
    }
    NSUInteger idx = [episodes indexOfObjectPassingTest:^BOOL(PCEpisode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.order == ep.episodeOrder;
    }];
    PCComicPictureController *reader = [[PCComicPictureController alloc] initOfflineWithComic:self.record
                                                                                episodeArray:episodes
                                                                                       index:idx != NSNotFound ? idx : 0];
    [self.navigationController pushViewController:reader animated:YES];
}

#pragma mark - Helper

- (NSString *)statusTextForStatus:(NSInteger)status {
    switch (status) {
        case PCComicDownloadStatusQueued:      return @"等待中";
        case PCComicDownloadStatusDownloading: return @"下载中";
        case PCComicDownloadStatusPaused:      return @"已暂停";
        case PCComicDownloadStatusFinished:    return @"已完成";
        case PCComicDownloadStatusFailed:      return @"下载失败";
        default: return @"";
    }
}

@end