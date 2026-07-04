//
//  PCDownloadPath.h
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 下载模块的路径工具类，所有下载相关目录/文件位置均由此计算。
/// 目录结构：
///   Documents/PCDownload/
///   ├─ PC_DB_USER_<userId>_download.sqlite   ← GYDataCenter DB
///   └─ <comicId>/
///      ├─ cover.jpg
///      ├─ meta.json
///      └─ <order>/
///         ├─ 000.jpg
///         └─ ...
@interface PCDownloadPath : NSObject

/// Documents/PCDownload/，首次访问时懒建。
+ (NSString *)rootDirectory;

/// Documents/PCDownload/<comicId>/，首次访问时懒建。
+ (NSString *)directoryForComicId:(NSString *)comicId;

/// Documents/PCDownload/<comicId>/<order>/，首次访问时懒建。
+ (NSString *)directoryForComicId:(NSString *)comicId
                            order:(NSInteger)order;

/// 单张图片本地绝对路径，文件名按 pageIndex zero-pad 3 位（000.jpg / 001.png ...）。
/// extension 传入不带点的后缀，例如 @"jpg"。若为空则默认 @"jpg"。
+ (NSString *)localPathForComicId:(NSString *)comicId
                            order:(NSInteger)order
                        pageIndex:(NSInteger)pageIndex
                        extension:(nullable NSString *)extension;

/// 封面本地路径 Documents/PCDownload/<comicId>/cover.jpg
+ (NSString *)coverPathForComicId:(NSString *)comicId;

/// 元数据快照本地路径 Documents/PCDownload/<comicId>/meta.json
+ (NSString *)metaPathForComicId:(NSString *)comicId;

/// 设备剩余可用空间（字节）；查询失败返回 LLONG_MAX，避免误伤触发磁盘满逻辑。
+ (long long)freeDiskSpace;

/// 下载根目录总占用（字节），异步计算前先切到后台队列使用。
+ (long long)totalDownloadFolderSize;

@end

NS_ASSUME_NONNULL_END
