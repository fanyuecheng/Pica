//
//  PCDownloadManager.m
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCDownloadManager.h"
#import "PCDownloadPath.h"
#import "PCComicDownload.h"
#import "PCComicDownloadEpisode.h"
#import "PCComicDownloadPicture.h"
#import "PCComic.h"
#import "PCEpisode.h"
#import "PCPicture.h"
#import "PCThumb.h"
#import "PCComicEpisodeRequest.h"
#import "PCComicPictureRequest.h"
#import "PCDefineHeader.h"
#import <SDWebImage/SDWebImage.h>
#import <UserNotifications/UserNotifications.h>

#pragma mark - Notification names

NSNotificationName const PCDownloadDidEnqueueNotification         = @"PCDownloadDidEnqueueNotification";
NSNotificationName const PCDownloadDidUpdateProgressNotification  = @"PCDownloadDidUpdateProgressNotification";
NSNotificationName const PCDownloadDidChangeStatusNotification    = @"PCDownloadDidChangeStatusNotification";
NSNotificationName const PCDownloadDidCompleteComicNotification   = @"PCDownloadDidCompleteComicNotification";
NSNotificationName const PCDownloadDidDeleteComicNotification     = @"PCDownloadDidDeleteComicNotification";

NSString * const PCDownloadNotificationComicIdKey    = @"comicId";
NSString * const PCDownloadNotificationStatusKey     = @"status";
NSString * const PCDownloadNotificationDownloadedKey = @"downloaded";
NSString * const PCDownloadNotificationTotalKey      = @"total";

#pragma mark -

@interface PCDownloadManager ()

/// 状态与 DB 变更的串行队列
@property (nonatomic, strong) dispatch_queue_t serialQueue;
/// 单话内图片下载的并发队列
@property (nonatomic, strong) NSOperationQueue *imageQueue;
/// 等待下载的 comicId 队列
@property (nonatomic, strong) NSMutableArray<NSString *> *pendingComicIds;
/// 当前活跃下载的 comicId（nil 表示无活跃任务）
@property (nonatomic, copy, nullable) NSString *activeComicId;

@end

@implementation PCDownloadManager

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static PCDownloadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _serialQueue = dispatch_queue_create("com.pica.download.state", DISPATCH_QUEUE_SERIAL);
        _imageQueue = [[NSOperationQueue alloc] init];
        _imageQueue.maxConcurrentOperationCount = 3;
        _imageQueue.name = @"com.pica.download.images";
        _pendingComicIds = [NSMutableArray array];
        [self bootstrap];
    }
    return self;
}

#pragma mark - Public API

- (void)startDownloadForComic:(PCComic *)comic {
    if (comic.comicId.length == 0) return;
    PCComic *snapshot = comic; // block 内需要基本字段做首次落表
    dispatch_async(self.serialQueue, ^{
        PCComicDownload *record = (PCComicDownload *)[PCComicDownload objectForId:snapshot.comicId];
        if (record) {
            // 已存在
            if (record.status == PCComicDownloadStatusQueued ||
                record.status == PCComicDownloadStatusDownloading ||
                record.status == PCComicDownloadStatusPaused) {
                // 已在管道内，no-op（暂停中的漫画需要用户手动 resume）
                return;
            }
            // finished / failed → 重下：重置失败图片
            [self resetFailedPicturesForComicId:snapshot.comicId];
            record.status = PCComicDownloadStatusQueued;
            record.updatedAt = [[NSDate date] timeIntervalSince1970];
            [record save];
        } else {
            record = [PCComicDownload objectWithDictionary:@{
                @"comicId":           snapshot.comicId,
                @"title":             snapshot.title ?: @"",
                @"author":            snapshot.author ?: @"",
                @"thumbUrl":          snapshot.thumb.imageURL ?: @"",
                @"epsCount":          @(snapshot.epsCount),
                @"totalPictures":     @0,
                @"downloadedPictures":@0,
                @"createdAt":         @([[NSDate date] timeIntervalSince1970]),
                @"updatedAt":         @([[NSDate date] timeIntervalSince1970]),
                @"status":            @(PCComicDownloadStatusQueued)
            }];
            [record save];
        }
        [self.pendingComicIds addObject:snapshot.comicId];
        [self postNotification:PCDownloadDidEnqueueNotification
                       comicId:snapshot.comicId
                      userInfo:nil];
        [self drainQueue];
    });
}

- (void)pauseComicId:(NSString *)comicId {
    if (comicId.length == 0) return;
    dispatch_async(self.serialQueue, ^{
        [self.pendingComicIds removeObject:comicId];
        PCComicDownload *record = (PCComicDownload *)[PCComicDownload objectForId:comicId];
        if (!record) return;
        BOOL wasActive = [self.activeComicId isEqualToString:comicId];
        if (wasActive) {
            [self.imageQueue cancelAllOperations];
            self.activeComicId = nil;
        }
        if (record.status == PCComicDownloadStatusQueued ||
            record.status == PCComicDownloadStatusDownloading) {
            record.status = PCComicDownloadStatusPaused;
            record.updatedAt = [[NSDate date] timeIntervalSince1970];
            [record save];
            [self postStatusChange:comicId status:record.status];
        }
        if (wasActive) {
            [self drainQueue];
        }
    });
}

- (void)resumeComicId:(NSString *)comicId {
    if (comicId.length == 0) return;
    dispatch_async(self.serialQueue, ^{
        PCComicDownload *record = (PCComicDownload *)[PCComicDownload objectForId:comicId];
        if (!record) return;
        if (record.status != PCComicDownloadStatusPaused &&
            record.status != PCComicDownloadStatusFailed) {
            return;
        }
        [self resetFailedPicturesForComicId:comicId];
        record.status = PCComicDownloadStatusQueued;
        record.updatedAt = [[NSDate date] timeIntervalSince1970];
        [record save];
        [self postStatusChange:comicId status:record.status];
        if (![self.pendingComicIds containsObject:comicId]) {
            [self.pendingComicIds addObject:comicId];
        }
        [self drainQueue];
    });
}

- (void)retryComicId:(NSString *)comicId {
    [self resumeComicId:comicId];
}

- (void)deleteComicId:(NSString *)comicId {
    if (comicId.length == 0) return;
    dispatch_async(self.serialQueue, ^{
        [self.pendingComicIds removeObject:comicId];
        if ([self.activeComicId isEqualToString:comicId]) {
            [self.imageQueue cancelAllOperations];
            self.activeComicId = nil;
        }
        // 删磁盘
        NSString *dir = [PCDownloadPath directoryForComicId:comicId];
        [kDefaultFileManager removeItemAtPath:dir error:nil];
        // 删 DB
        [PCComicDownloadPicture deleteObjectsWhere:@"WHERE comicId = ?" arguments:@[comicId]];
        [PCComicDownloadEpisode deleteObjectsWhere:@"WHERE comicId = ?"  arguments:@[comicId]];
        [PCComicDownload        deleteObjectsWhere:@"WHERE comicId = ?"  arguments:@[comicId]];
        [self postNotification:PCDownloadDidDeleteComicNotification
                       comicId:comicId
                      userInfo:nil];
        [self drainQueue];
    });
}

- (void)deleteAll {
    dispatch_async(self.serialQueue, ^{
        [self.imageQueue cancelAllOperations];
        self.activeComicId = nil;
        [self.pendingComicIds removeAllObjects];
        // 删磁盘：整个 PCDownload 根目录清空
        NSString *root = [PCDownloadPath rootDirectory];
        NSError *err = nil;
        NSArray *children = [kDefaultFileManager contentsOfDirectoryAtPath:root error:&err];
        for (NSString *child in children) {
            [kDefaultFileManager removeItemAtPath:[root stringByAppendingPathComponent:child] error:nil];
        }
        // 删 DB
        [PCComicDownloadPicture deleteObjectsWhere:nil arguments:nil];
        [PCComicDownloadEpisode deleteObjectsWhere:nil arguments:nil];
        [PCComicDownload        deleteObjectsWhere:nil arguments:nil];
    });
}

- (PCComicDownload *)recordForComicId:(NSString *)comicId {
    if (comicId.length == 0) return nil;
    return (PCComicDownload *)[PCComicDownload objectForId:comicId];
}

- (NSArray<PCComicDownload *> *)allDownloadsSortedByCreatedAtDesc {
    NSArray *all = [PCComicDownload objectsWhere:@"ORDER BY createdAt DESC" arguments:nil];
    return all ?: @[];
}

#pragma mark - Bootstrap

/// App 启动 / 首次访问时从 DB 载入未完成的下载。
- (void)bootstrap {
    dispatch_async(self.serialQueue, ^{
        [self ensureTables];
        NSArray<PCComicDownload *> *inflight = [PCComicDownload objectsWhere:@"WHERE status IN (?, ?) ORDER BY createdAt ASC"
                                                                  arguments:@[@(PCComicDownloadStatusQueued),
                                                                              @(PCComicDownloadStatusDownloading)]];
        for (PCComicDownload *record in inflight) {
            // downloading 状态实际未跑，回落到 queued
            if (record.status == PCComicDownloadStatusDownloading) {
                record.status = PCComicDownloadStatusQueued;
                [record save];
            }
            if (![self.pendingComicIds containsObject:record.comicId]) {
                [self.pendingComicIds addObject:record.comicId];
            }
        }
        [self drainQueue];
    });
}

#pragma mark - Queue Driver

/// 若无活跃任务且有 pending，拉起第一个开始下载。必须在 serialQueue 调用。
- (void)drainQueue {
    if (self.activeComicId) return;
    if (self.pendingComicIds.count == 0) return;
    NSString *comicId = [self.pendingComicIds firstObject];
    [self.pendingComicIds removeObjectAtIndex:0];
    self.activeComicId = comicId;

    PCComicDownload *record = (PCComicDownload *)[PCComicDownload objectForId:comicId];
    if (!record) {
        // 记录不见了（可能被删），转下一个
        self.activeComicId = nil;
        [self drainQueue];
        return;
    }
    record.status = PCComicDownloadStatusDownloading;
    record.updatedAt = [[NSDate date] timeIntervalSince1970];
    [record save];
    [self postStatusChange:comicId status:record.status];

    [self runComicId:comicId];
}

#pragma mark - Runner: episode fetch

- (void)runComicId:(NSString *)comicId {
    // 步骤 1: 拉所有章节
    [self fetchAllEpisodesForComicId:comicId
                              onPage:1
                          completion:^(BOOL success) {
        dispatch_async(self.serialQueue, ^{
            if (![self.activeComicId isEqualToString:comicId]) return; // 被打断
            if (!success) {
                [self markComicFailed:comicId];
                return;
            }
            [self downloadNextEpisodeForComicId:comicId];
        });
    }];
}

- (void)fetchAllEpisodesForComicId:(NSString *)comicId
                            onPage:(NSInteger)page
                        completion:(void (^)(BOOL success))completion {
    PCComicEpisodeRequest *req = [[PCComicEpisodeRequest alloc] initWithComicId:comicId];
    req.page = page;
    [req sendRequest:^(PCComicEpisode *episode) {
        dispatch_async(self.serialQueue, ^{
            if (![self.activeComicId isEqualToString:comicId]) return;
            // upsert 章节
            for (PCEpisode *ep in episode.docs) {
                NSString *uid = [PCComicDownloadEpisode episodeUidForComicId:comicId order:ep.order];
                PCComicDownloadEpisode *existing = (PCComicDownloadEpisode *)[PCComicDownloadEpisode objectForId:uid];
                if (existing) {
                    existing.title = ep.title ?: existing.title;
                    [existing save];
                } else {
                    PCComicDownloadEpisode *row = [PCComicDownloadEpisode objectWithDictionary:@{
                        @"episodeUid":     uid,
                        @"comicId":        comicId,
                        @"episodeOrder":   @(ep.order),
                        @"title":          ep.title ?: @"",
                        @"totalPages":     @0,
                        @"downloadedPages":@0,
                        @"status":         @(PCComicDownloadStatusQueued)
                    }];
                    [row save];
                }
            }
            // 更新主表 epsCount
            PCComicDownload *record = (PCComicDownload *)[PCComicDownload objectForId:comicId];
            if (record && record.epsCount < episode.total) {
                record.epsCount = episode.total;
                [record save];
            }
            if (episode.page < episode.pages) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), self.serialQueue, ^{
                    if (![self.activeComicId isEqualToString:comicId]) return;
                    [self fetchAllEpisodesForComicId:comicId onPage:episode.page + 1 completion:completion];
                });
            } else {
                completion(YES);
            }
        });
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(self.serialQueue, ^{
            completion(NO);
        });
    }];
}

#pragma mark - Runner: episode loop

/// 在 serialQueue 调用。找到下一话未完成的章节并开始下图。全部完成则收尾。
- (void)downloadNextEpisodeForComicId:(NSString *)comicId {
    NSArray<PCComicDownloadEpisode *> *episodes = [PCComicDownloadEpisode
        objectsWhere:@"WHERE comicId = ? AND status != ? ORDER BY episodeOrder ASC"
        arguments:@[comicId, @(PCComicDownloadStatusFinished)]];
    if (episodes.count == 0) {
        [self markComicFinished:comicId];
        return;
    }
    PCComicDownloadEpisode *next = episodes.firstObject;
    next.status = PCComicDownloadStatusDownloading;
    [next save];

    [self fetchAllPicturesForComicId:comicId
                               order:next.episodeOrder
                              onPage:1
                          completion:^(BOOL success) {
        dispatch_async(self.serialQueue, ^{
            if (![self.activeComicId isEqualToString:comicId]) return;
            if (!success) {
                next.status = PCComicDownloadStatusFailed;
                [next save];
                // 单话失败不阻塞后续，继续下一话
                [self downloadNextEpisodeForComicId:comicId];
                return;
            }
            [self downloadPicturesForComicId:comicId order:next.episodeOrder episodeUid:next.episodeUid];
        });
    }];
}

- (void)fetchAllPicturesForComicId:(NSString *)comicId
                             order:(NSInteger)order
                            onPage:(NSInteger)page
                        completion:(void (^)(BOOL success))completion {
    PCComicPictureRequest *req = [[PCComicPictureRequest alloc] initWithComicId:comicId order:order];
    req.page = page;
    [req sendRequest:^(PCEpisodePicture *picture) {
        dispatch_async(self.serialQueue, ^{
            if (![self.activeComicId isEqualToString:comicId]) return;
            // 用当前 DB 已存的该话图片数作为 base index，避免依赖服务端 limit
            NSNumber *existingCount = [PCComicDownloadPicture aggregate:@"count(*)"
                                                                  where:@"WHERE comicId = ? AND episodeOrder = ?"
                                                              arguments:@[comicId, @(order)]];
            __block NSInteger nextIndex = existingCount.integerValue;
            [picture.docs enumerateObjectsUsingBlock:^(PCPicture * _Nonnull p, NSUInteger idx, BOOL * _Nonnull stop) {
                if (p.pictureId.length == 0) return;
                PCComicDownloadPicture *existing = (PCComicDownloadPicture *)[PCComicDownloadPicture objectForId:p.pictureId];
                if (existing) {
                    // 只覆盖 URL 和 originalName，保留 status/localPath/pageIndex
                    existing.remoteUrl = p.media.imageURL ?: existing.remoteUrl;
                    existing.originalName = p.media.originalName ?: existing.originalName;
                    // 校验 localPath 是否仍然存在，缺失则回落 pending
                    if (existing.status == PCComicDownloadPictureStatusDone &&
                        (existing.localPath.length == 0 || ![kDefaultFileManager fileExistsAtPath:existing.localPath])) {
                        existing.status = PCComicDownloadPictureStatusPending;
                    }
                    [existing save];
                } else {
                    PCComicDownloadPicture *row = [PCComicDownloadPicture objectWithDictionary:@{
                        @"pictureId":    p.pictureId,
                        @"comicId":      comicId,
                        @"episodeOrder": @(order),
                        @"pageIndex":    @(nextIndex),
                        @"originalName": p.media.originalName ?: @"",
                        @"remoteUrl":    p.media.imageURL ?: @"",
                        @"localPath":    @"",
                        @"status":       @(PCComicDownloadPictureStatusPending)
                    }];
                    [row save];
                    nextIndex++;
                }
            }];
            // 更新章节 totalPages
            NSString *uid = [PCComicDownloadEpisode episodeUidForComicId:comicId order:order];
            PCComicDownloadEpisode *ep = (PCComicDownloadEpisode *)[PCComicDownloadEpisode objectForId:uid];
            if (ep && ep.totalPages < picture.total) {
                ep.totalPages = picture.total;
                [ep save];
            }
            // 更新主表 totalPictures 需要在图片入库后重新计算（简单起见每次收到新页都累加 total）
            if (picture.page == 1) {
                [self recomputeTotalsForComicId:comicId];
            }
            if (picture.page < picture.pages) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), self.serialQueue, ^{
                    if (![self.activeComicId isEqualToString:comicId]) return;
                    [self fetchAllPicturesForComicId:comicId order:order onPage:picture.page + 1 completion:completion];
                });
            } else {
                [self recomputeTotalsForComicId:comicId];
                completion(YES);
            }
        });
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(self.serialQueue, ^{
            completion(NO);
        });
    }];
}

#pragma mark - Runner: picture download

/// 在 serialQueue 调用。取该话所有 status != done 的图片入 imageQueue。
- (void)downloadPicturesForComicId:(NSString *)comicId
                             order:(NSInteger)order
                        episodeUid:(NSString *)episodeUid {
    NSArray<PCComicDownloadPicture *> *pending = [PCComicDownloadPicture
        objectsWhere:@"WHERE comicId = ? AND episodeOrder = ? AND status != ? ORDER BY pageIndex ASC"
        arguments:@[comicId, @(order), @(PCComicDownloadPictureStatusDone)]];

    if (pending.count == 0) {
        // 该话未完成的图片为 0。可能是：
        //   (a) 图片已全部下载完成 → episode finished
        //   (b) fetchAll 返回空 docs（服务端异常 / 空章节）→ 图片表根本没有行，应标 failed
        NSNumber *totalCount = [PCComicDownloadPicture aggregate:@"count(*)"
                                                            where:@"WHERE comicId = ? AND episodeOrder = ?"
                                                        arguments:@[comicId, @(order)]];
        PCComicDownloadEpisode *ep = (PCComicDownloadEpisode *)[PCComicDownloadEpisode objectForId:episodeUid];
        if (ep) {
            ep.status = totalCount.integerValue > 0 ? PCComicDownloadStatusFinished
                                                    : PCComicDownloadStatusFailed;
            [ep save];
        }
        [self downloadNextEpisodeForComicId:comicId];
        return;
    }

    // 每完成一张调 -pictureDidFinish:comicId:order:episodeUid:；统计计数以判断整话完成
    __block NSInteger remaining = pending.count;
    for (PCComicDownloadPicture *pic in pending) {
        NSString *pictureId = pic.pictureId;
        __weak __typeof(self) weakSelf = self;
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            __strong __typeof(weakSelf) self = weakSelf;
            if (!self) return;
            // 已开始的下载无法中断，但完成回调时会用 activeComicId 检查是否还应落库
            [self downloadOneComicId:comicId
                               order:order
                           pictureId:pictureId
                          completion:^(BOOL succeeded){
                dispatch_async(self.serialQueue, ^{
                    if (![self.activeComicId isEqualToString:comicId]) return;
                    [self applyPictureResultForComicId:comicId
                                            pictureId:pictureId
                                            succeeded:succeeded];
                    remaining--;
                    if (remaining == 0) {
                        // 该话跑完（不管是否全部成功）
                        [self finishEpisodeForComicId:comicId
                                           episodeUid:episodeUid];
                    }
                });
            }];
        }];
        [self.imageQueue addOperation:op];
    }
}

/// 该话跑完：若全部图片 done → episode finished；否则 failed。然后进下一话。
- (void)finishEpisodeForComicId:(NSString *)comicId
                     episodeUid:(NSString *)episodeUid {
    PCComicDownloadEpisode *ep = (PCComicDownloadEpisode *)[PCComicDownloadEpisode objectForId:episodeUid];
    if (!ep) {
        [self downloadNextEpisodeForComicId:comicId];
        return;
    }
    NSNumber *undoneCount = [PCComicDownloadPicture aggregate:@"count(*)"
                                                        where:@"WHERE comicId = ? AND episodeOrder = ? AND status != ?"
                                                    arguments:@[comicId, @(ep.episodeOrder), @(PCComicDownloadPictureStatusDone)]];
    if (undoneCount.integerValue == 0) {
        ep.status = PCComicDownloadStatusFinished;
    } else {
        ep.status = PCComicDownloadStatusFailed;
    }
    [ep save];
    [self downloadNextEpisodeForComicId:comicId];
}

#pragma mark - Runner: single picture download

/// 在 imageQueue 线程调用。加载 → 拷贝到目标路径。任务 8 会在此加重试与磁盘检查。
- (void)downloadOneComicId:(NSString *)comicId
                     order:(NSInteger)order
                 pictureId:(NSString *)pictureId
                completion:(void (^)(BOOL succeeded))completion {
    PCComicDownloadPicture *pic = (PCComicDownloadPicture *)[PCComicDownloadPicture objectForId:pictureId];
    if (!pic || pic.remoteUrl.length == 0) {
        completion(NO);
        return;
    }
    NSURL *url = [NSURL URLWithString:pic.remoteUrl];
    if (!url) {
        // URL 含未编码字符，尝试百分号编码
        NSString *encoded = [pic.remoteUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url = [NSURL URLWithString:encoded];
    }
    if (!url) {
#if defined(DEBUG)
        NSLog(@"[PCDownload] invalid url: %@", pic.remoteUrl);
#endif
        completion(NO);
        return;
    }
    NSString *ext = [pic.originalName pathExtension];
    if (ext.length == 0) ext = @"jpg";
    NSString *targetPath = [PCDownloadPath localPathForComicId:comicId
                                                         order:order
                                                     pageIndex:pic.pageIndex
                                                     extension:ext];

    [[SDWebImageManager sharedManager]
        loadImageWithURL:url
                 options:SDWebImageRetryFailed
                 context:nil
                progress:nil
               completed:^(UIImage * _Nullable image,
                           NSData * _Nullable data,
                           NSError * _Nullable error,
                           SDImageCacheType cacheType,
                           BOOL finished,
                           NSURL * _Nullable imageURL) {
        if (error || !finished || !image) {
            completion(NO);
            return;
        }
        // 优先用原始 data 直接写盘（最可靠）；否则 fallback 到 UIImageJPEGRepresentation
        BOOL ok = NO;
        if (data.length) {
            ok = [data writeToFile:targetPath atomically:YES];
        } else {
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            if (!imageData) {
                imageData = UIImagePNGRepresentation(image);
            }
            ok = [imageData writeToFile:targetPath atomically:YES];
        }
        if (!ok) {
#if defined(DEBUG)
            NSLog(@"[PCDownload] write failed: %@", targetPath);
#endif
        }
        completion(ok);
    }];
}

/// 在 serialQueue 调用。落库 + 进度通知。
- (void)applyPictureResultForComicId:(NSString *)comicId
                           pictureId:(NSString *)pictureId
                           succeeded:(BOOL)succeeded {
    PCComicDownloadPicture *pic = (PCComicDownloadPicture *)[PCComicDownloadPicture objectForId:pictureId];
    if (!pic) return;
    if (succeeded) {
        NSString *ext = [pic.originalName pathExtension];
        if (ext.length == 0) ext = @"jpg";
        pic.localPath = [PCDownloadPath localPathForComicId:comicId
                                                      order:pic.episodeOrder
                                                  pageIndex:pic.pageIndex
                                                  extension:ext];
        pic.status = PCComicDownloadPictureStatusDone;
    } else {
        pic.status = PCComicDownloadPictureStatusFailed;
    }
    [pic save];
    if (!succeeded) return;

    // 精确重算章节 / 主表的 downloadedPages / downloadedPictures，避免 ++ 累加错乱
    [self recomputeCountersForComicId:comicId episodeOrder:pic.episodeOrder];

    PCComicDownload *record = (PCComicDownload *)[PCComicDownload objectForId:comicId];
    if (record) {
        [self postNotification:PCDownloadDidUpdateProgressNotification
                       comicId:comicId
                      userInfo:@{
                          PCDownloadNotificationDownloadedKey: @(record.downloadedPictures),
                          PCDownloadNotificationTotalKey:      @(record.totalPictures)
                      }];
    }
}

/// 精确计数：一次性 count(*) 完成 done 的图片数，写入章节表 / 主表。
- (void)recomputeCountersForComicId:(NSString *)comicId
                       episodeOrder:(NSInteger)episodeOrder {
    NSString *episodeUid = [PCComicDownloadEpisode episodeUidForComicId:comicId order:episodeOrder];
    PCComicDownloadEpisode *ep = (PCComicDownloadEpisode *)[PCComicDownloadEpisode objectForId:episodeUid];
    if (ep) {
        NSNumber *epDone = [PCComicDownloadPicture aggregate:@"count(*)"
                                                        where:@"WHERE comicId = ? AND episodeOrder = ? AND status = ?"
                                                    arguments:@[comicId, @(episodeOrder), @(PCComicDownloadPictureStatusDone)]];
        ep.downloadedPages = epDone.integerValue;
        [ep save];
    }
    NSNumber *comicDone = [PCComicDownloadPicture aggregate:@"count(*)"
                                                       where:@"WHERE comicId = ? AND status = ?"
                                                   arguments:@[comicId, @(PCComicDownloadPictureStatusDone)]];
    PCComicDownload *record = (PCComicDownload *)[PCComicDownload objectForId:comicId];
    if (record) {
        record.downloadedPictures = comicDone.integerValue;
        record.updatedAt = [[NSDate date] timeIntervalSince1970];
        [record save];
    }
}

#pragma mark - Completion / failure

- (void)markComicFinished:(NSString *)comicId {
    PCComicDownload *record = (PCComicDownload *)[PCComicDownload objectForId:comicId];
    if (record) {
        // 防御：若 totalPictures==0，说明所有话都是空 finished（服务端/网络异常），不能当"已下载"
        if (record.totalPictures == 0) {
            record.status = PCComicDownloadStatusFailed;
        } else {
            record.status = PCComicDownloadStatusFinished;
        }
        record.updatedAt = [[NSDate date] timeIntervalSince1970];
        [record save];
        [self postStatusChange:comicId status:record.status];
        if (record.status == PCComicDownloadStatusFinished) {
            [self postNotification:PCDownloadDidCompleteComicNotification
                           comicId:comicId
                          userInfo:nil];
            [self fireLocalNotificationForRecord:record];
        }
    }
    self.activeComicId = nil;
    [self drainQueue];
}

#pragma mark - Local notification

/// 完成整本时弹本地通知。首次调用会请求授权；用户拒绝则静默。
- (void)fireLocalNotificationForRecord:(PCComicDownload *)record {
    NSString *title = record.title.length ? record.title : @"漫画";
    NSString *body = [NSString stringWithFormat:@"《%@》已下载完成（%ld 张）", title, (long)record.downloadedPictures];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        void (^schedule)(void) = ^{
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = @"下载完成";
            content.body = body;
            content.sound = UNNotificationSound.defaultSound;
            NSString *reqId = [NSString stringWithFormat:@"pc.download.%@", record.comicId];
            UNNotificationRequest *req = [UNNotificationRequest requestWithIdentifier:reqId
                                                                              content:content
                                                                              trigger:nil];
            [center addNotificationRequest:req withCompletionHandler:nil];
        };

        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized ||
            settings.authorizationStatus == UNAuthorizationStatusProvisional) {
            schedule();
        } else if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
            // 首次静默请求授权
            [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound
                                  completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) schedule();
            }];
        }
        // Denied → 静默不发
    }];
}

- (void)markComicFailed:(NSString *)comicId {
    PCComicDownload *record = (PCComicDownload *)[PCComicDownload objectForId:comicId];
    if (record) {
        record.status = PCComicDownloadStatusFailed;
        record.updatedAt = [[NSDate date] timeIntervalSince1970];
        [record save];
        [self postStatusChange:comicId status:record.status];
    }
    self.activeComicId = nil;
    [self drainQueue];
}

#pragma mark - DB helpers

- (void)resetFailedPicturesForComicId:(NSString *)comicId {
    [PCComicDownloadPicture updateObjectsSet:@{@"status": @(PCComicDownloadPictureStatusPending)}
                                        Where:@"WHERE comicId = ? AND status = ?"
                                    arguments:@[comicId, @(PCComicDownloadPictureStatusFailed)]];
    // 章节状态也回落
    [PCComicDownloadEpisode updateObjectsSet:@{@"status": @(PCComicDownloadStatusQueued)}
                                        Where:@"WHERE comicId = ? AND status = ?"
                                    arguments:@[comicId, @(PCComicDownloadStatusFailed)]];

    // 重算所有章节的 downloadedPages / 主表 downloadedPictures，防止旧 ++ 计数残留
    NSArray<PCComicDownloadEpisode *> *allEps = [PCComicDownloadEpisode
        objectsWhere:@"WHERE comicId = ?" arguments:@[comicId]];
    for (PCComicDownloadEpisode *ep in allEps) {
        [self recomputeCountersForComicId:comicId episodeOrder:ep.episodeOrder];
    }
}

- (void)recomputeTotalsForComicId:(NSString *)comicId {
    NSNumber *total = [PCComicDownloadPicture aggregate:@"count(*)"
                                                   where:@"WHERE comicId = ?"
                                               arguments:@[comicId]];
    NSNumber *done  = [PCComicDownloadPicture aggregate:@"count(*)"
                                                   where:@"WHERE comicId = ? AND status = ?"
                                               arguments:@[comicId, @(PCComicDownloadPictureStatusDone)]];
    PCComicDownload *record = (PCComicDownload *)[PCComicDownload objectForId:comicId];
    if (record) {
        record.totalPictures      = total.integerValue;
        record.downloadedPictures = done.integerValue;
        [record save];
    }
}

#pragma mark - Table creation

/// GYDataCenter 在 `save` 时才创建表。确保 3 张表在首次查询前已存在。
- (void)ensureTables {
    // 主表 PCComicDownload 已在 startDownloadForComic: 中自然建表
    // Episode 表
    PCComicDownloadEpisode *dummyEp = [PCComicDownloadEpisode objectWithDictionary:@{
        @"episodeUid": @"__create__",
        @"comicId":    @"__create__",
        @"episodeOrder": @0,
        @"title":      @""
    }];
    [dummyEp save];
    [dummyEp deleteObject];
    // Picture 表
    PCComicDownloadPicture *dummyPic = [PCComicDownloadPicture objectWithDictionary:@{
        @"pictureId":    @"__create__",
        @"comicId":      @"__create__",
        @"episodeOrder": @0,
        @"pageIndex":    @0
    }];
    [dummyPic save];
    [dummyPic deleteObject];
}

#pragma mark - Notification helpers

- (void)postNotification:(NSNotificationName)name
                 comicId:(NSString *)comicId
                userInfo:(nullable NSDictionary *)extra {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (comicId) userInfo[PCDownloadNotificationComicIdKey] = comicId;
    if (extra) [userInfo addEntriesFromDictionary:extra];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                            object:self
                                                          userInfo:userInfo];
    });
}

- (void)postStatusChange:(NSString *)comicId status:(NSInteger)status {
    [self postNotification:PCDownloadDidChangeStatusNotification
                   comicId:comicId
                  userInfo:@{PCDownloadNotificationStatusKey: @(status)}];
}

@end
