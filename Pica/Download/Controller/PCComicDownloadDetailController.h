//
//  PCComicDownloadDetailController.h
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 单本漫画下载详情页：封面 + 总进度 + 各话状态列表、右上角暂停/继续/删除。
/// 点击已下载的话进入离线阅读器。
@interface PCComicDownloadDetailController : PCTableViewController

- (instancetype)initWithComicId:(NSString *)comicId;

@end

NS_ASSUME_NONNULL_END