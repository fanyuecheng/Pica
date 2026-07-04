//
//  PCComicDownloadListController.h
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCTableViewController.h"
#import <JXPagingView/JXPagerView.h>

NS_ASSUME_NONNULL_BEGIN

/// "我的" → "下载" Tab 的列表控制器。
/// 数据来源：PCDownloadManager.allDownloadsSortedByCreatedAtDesc
/// 支持左滑删除；空态展示"还没有下载的漫画"。
@interface PCComicDownloadListController : PCTableViewController <JXPagerViewListViewDelegate>

@end

NS_ASSUME_NONNULL_END
