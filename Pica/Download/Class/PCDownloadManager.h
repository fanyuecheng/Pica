//
//  PCDownloadManager.h
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCComic, PCComicDownload;

NS_ASSUME_NONNULL_BEGIN

#define kPCDownloadManager  [PCDownloadManager sharedManager]

#pragma mark - Notifications

/// userInfo: comicId
FOUNDATION_EXPORT NSNotificationName const PCDownloadDidEnqueueNotification;
/// userInfo: comicId, downloadedPictures, totalPictures
FOUNDATION_EXPORT NSNotificationName const PCDownloadDidUpdateProgressNotification;
/// userInfo: comicId, status
FOUNDATION_EXPORT NSNotificationName const PCDownloadDidChangeStatusNotification;
/// userInfo: comicId
FOUNDATION_EXPORT NSNotificationName const PCDownloadDidCompleteComicNotification;
/// userInfo: comicId
FOUNDATION_EXPORT NSNotificationName const PCDownloadDidDeleteComicNotification;

FOUNDATION_EXPORT NSString * const PCDownloadNotificationComicIdKey;
FOUNDATION_EXPORT NSString * const PCDownloadNotificationStatusKey;
FOUNDATION_EXPORT NSString * const PCDownloadNotificationDownloadedKey;
FOUNDATION_EXPORT NSString * const PCDownloadNotificationTotalKey;

#pragma mark - Manager

/// 漫画下载协调器（单例）。
/// - 全局同一时刻仅一本漫画处于 downloading 态；其余入队 pending 排队
/// - 单话内使用 NSOperationQueue（max=3）并发下载图片
/// - 所有状态变更 / DB 写入 走 serialQueue，通知统一 dispatch main
/// - 每次开跑一话都会重新调 PCComicPictureRequest 拉最新图片 URL，不复用旧 URL
@interface PCDownloadManager : NSObject

+ (instancetype)sharedManager;

/// 入队一本漫画（幂等）。
/// - 已存在记录且 status ∈ {queued, downloading, paused}：no-op
/// - 已存在且 status ∈ {finished, failed}：视为重下，清 picture.status=failed 后续跑
/// - 记录不存在：新建 status=queued 落表，追加到 pending 队尾
- (void)startDownloadForComic:(PCComic *)comic;

/// 暂停指定漫画。若当前活跃 = comicId，会 cancel 全部图片 op 并把 activeComicId 释放。
- (void)pauseComicId:(NSString *)comicId;

/// 从 paused / failed 状态恢复到 queued，追加到 pending。
- (void)resumeComicId:(NSString *)comicId;

/// 重试失败的漫画（等价 resumeComicId:）。
- (void)retryComicId:(NSString *)comicId;

/// 删除一本漫画：cancel 活跃任务 → rmdir 图片目录 → 删 DB 3 张表对应行。
- (void)deleteComicId:(NSString *)comicId;

/// 清空当前用户所有下载（DB + 磁盘）。
- (void)deleteAll;

/// 查询主表记录，未命中返回 nil。可任意线程调用。
- (nullable PCComicDownload *)recordForComicId:(NSString *)comicId;

/// 按 createdAt 倒序返回全部下载记录。
- (NSArray<PCComicDownload *> *)allDownloadsSortedByCreatedAtDesc;

@end

NS_ASSUME_NONNULL_END
