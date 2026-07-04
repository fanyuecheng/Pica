//
//  PCComicDownloadEpisode.h
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GYDataCenter/GYDataCenter.h>

NS_ASSUME_NONNULL_BEGIN

/// 章节表：一行对应某本漫画的某一话。
/// 表名 PC_TABLE_COMIC_DOWNLOAD_EPISODE，主键 episodeUid（= comicId + "_" + order）。
/// status 枚举复用 PCComicDownloadStatus。
@interface PCComicDownloadEpisode : GYModelObject

@property (nonatomic, copy)   NSString *episodeUid;
@property (nonatomic, copy)   NSString *comicId;
@property (nonatomic, assign) NSInteger episodeOrder;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger downloadedPages;
@property (nonatomic, assign) NSInteger status;

/// 构造 episodeUid 的辅助方法（供 upsert / 查询）
+ (NSString *)episodeUidForComicId:(NSString *)comicId order:(NSInteger)order;

@end

NS_ASSUME_NONNULL_END
