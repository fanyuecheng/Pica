//
//  PCComicDownloadPicture.m
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCComicDownloadPicture.h"
#import "PCComicDownload.h"

@implementation PCComicDownloadPicture

#pragma mark - DB

+ (NSString *)dbName {
    return [PCComicDownload dbName];
}

+ (NSString *)tableName {
    return @"PC_TABLE_COMIC_DOWNLOAD_PICTURE";
}

+ (NSString *)primaryKey {
    return @"pictureId";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = @[
            @"pictureId",
            @"comicId",
            @"episodeOrder",
            @"pageIndex",
            @"originalName",
            @"remoteUrl",
            @"localPath",
            @"status"
        ];
    });
    return properties;
}

+ (NSArray *)indices {
    // 按 (comicId, episodeOrder) 拉一话所有图片；按 (comicId, episodeOrder, pageIndex) 排序展示
    return @[@[@"comicId", @"episodeOrder", @"pageIndex"]];
}

@end
