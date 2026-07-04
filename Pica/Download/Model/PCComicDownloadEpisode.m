//
//  PCComicDownloadEpisode.m
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCComicDownloadEpisode.h"
#import "PCComicDownload.h"

@implementation PCComicDownloadEpisode

+ (NSString *)episodeUidForComicId:(NSString *)comicId order:(NSInteger)order {
    return [NSString stringWithFormat:@"%@_%ld", comicId, (long)order];
}

#pragma mark - DB

+ (NSString *)dbName {
    // 与 PCComicDownload 落到同一 sqlite 文件
    return [PCComicDownload dbName];
}

+ (NSString *)tableName {
    return @"PC_TABLE_COMIC_DOWNLOAD_EPISODE";
}

+ (NSString *)primaryKey {
    return @"episodeUid";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = @[
            @"episodeUid",
            @"comicId",
            @"episodeOrder",
            @"title",
            @"totalPages",
            @"downloadedPages",
            @"status"
        ];
    });
    return properties;
}

+ (NSArray *)indices {
    // 一本漫画的所有章节按 episodeOrder 排序展示
    return @[@[@"comicId", @"episodeOrder"]];
}

@end
