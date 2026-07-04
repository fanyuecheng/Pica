//
//  PCComicDownload.h
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GYDataCenter/GYDataCenter.h>

NS_ASSUME_NONNULL_BEGIN

/// 单本漫画的下载状态。
typedef NS_ENUM(NSInteger, PCComicDownloadStatus) {
    PCComicDownloadStatusQueued      = 0, ///< 等待中，等 drainQueue 拉起
    PCComicDownloadStatusDownloading = 1, ///< 正在下载
    PCComicDownloadStatusPaused      = 2, ///< 已暂停（用户操作 or 磁盘满）
    PCComicDownloadStatusFinished    = 3, ///< 全部图片下载完成
    PCComicDownloadStatusFailed      = 4  ///< 3 次重试仍失败 / 章节请求失败
};

/// 下载主表：一行对应一本漫画。
/// 表名 PC_TABLE_COMIC_DOWNLOAD，主键 comicId。
@interface PCComicDownload : GYModelObject

@property (nonatomic, copy)   NSString *comicId;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *author;
@property (nonatomic, copy)   NSString *thumbUrl;         ///< 封面远程 URL
@property (nonatomic, assign) NSInteger epsCount;         ///< 总章节数
@property (nonatomic, assign) NSInteger totalPictures;    ///< 全本图片总数
@property (nonatomic, assign) NSInteger downloadedPictures; ///< 已下载图片数
@property (nonatomic, assign) NSTimeInterval createdAt;   ///< 加入队列时间戳
@property (nonatomic, assign) NSTimeInterval updatedAt;   ///< 最近状态变化时间戳
@property (nonatomic, assign) NSInteger status;           ///< PCComicDownloadStatus

/// 数据库文件绝对路径（仅供 Setting 页统计大小 / 调试使用；GYDataCenter 内部不调）。
+ (NSString *)dbPath;

@end

NS_ASSUME_NONNULL_END
