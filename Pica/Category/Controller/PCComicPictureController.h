//
//  PCComicPictureController.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCViewController.h"

@class PCComicDownload;
@class PCEpisode;

NS_ASSUME_NONNULL_BEGIN

@interface PCComicPictureController : PCViewController

@property (nonatomic, copy)   NSString *comicId;
@property (nonatomic, copy)   NSArray *episodeArray;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger historyEpisodeIndex;//第几张图
@property (nonatomic, assign) NSInteger historyEpisodePage;//第几页

- (instancetype)initWithComicId:(NSString *)comicId;

/// 离线阅读初始化（从本地磁盘加载，不走网络）
- (instancetype)initOfflineWithComic:(PCComicDownload *)comic
                        episodeArray:(NSArray<PCEpisode *> *)episodes
                               index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
