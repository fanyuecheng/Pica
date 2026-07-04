//
//  PCComicDownloadPicture.h
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GYDataCenter/GYDataCenter.h>

NS_ASSUME_NONNULL_BEGIN

/// 单张图片的下载状态。
typedef NS_ENUM(NSInteger, PCComicDownloadPictureStatus) {
    PCComicDownloadPictureStatusPending = 0,
    PCComicDownloadPictureStatusDone    = 1,
    PCComicDownloadPictureStatusFailed  = 2
};

/// 图片表：一行对应某一话中的一张图片。
/// 表名 PC_TABLE_COMIC_DOWNLOAD_PICTURE，主键 pictureId。
@interface PCComicDownloadPicture : GYModelObject

@property (nonatomic, copy)   NSString *pictureId;
@property (nonatomic, copy)   NSString *comicId;
@property (nonatomic, assign) NSInteger episodeOrder; ///< 所属章节 episodeOrder
@property (nonatomic, assign) NSInteger pageIndex;     ///< 页内序号（0-based）
@property (nonatomic, copy)   NSString *originalName;  ///< 服务端原始文件名
@property (nonatomic, copy)   NSString *remoteUrl;     ///< 图片远程 URL（每次开跑刷新）
@property (nonatomic, copy)   NSString *localPath;     ///< 本地绝对路径（相对 Documents 也可，一期用绝对）
@property (nonatomic, assign) NSInteger status;        ///< PCComicDownloadPictureStatus

@end

NS_ASSUME_NONNULL_END
