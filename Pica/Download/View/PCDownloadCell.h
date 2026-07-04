//
//  PCDownloadCell.h
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCTableViewCell.h"

@class PCComicDownload;

NS_ASSUME_NONNULL_BEGIN

/// 下载列表 cell：封面 + 标题 + 作者 + 状态文案 + 进度条。
/// 内部按 record.comicId 过滤 PCDownloadDidUpdateProgressNotification 做局部刷新，
/// -prepareForReuse 时移除观察，避免复用串号。
@interface PCDownloadCell : PCTableViewCell

- (void)configureWithRecord:(PCComicDownload *)record;

@end

NS_ASSUME_NONNULL_END
