//
//  PCComicDownload.m
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCComicDownload.h"
#import "PCUser.h"

@implementation PCComicDownload

#pragma mark - DB

+ (NSString *)dbPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return [documentsDirectory stringByAppendingPathComponent:[[self dbName] stringByAppendingPathExtension:@"db"]];
}

+ (NSString *)dbName {
    NSString *userId = [PCUser localUser].userId ?: @"anonymous";
    return [NSString stringWithFormat:@"PC_DB_USER_%@_download", userId];
}

+ (NSString *)tableName {
    return @"PC_TABLE_COMIC_DOWNLOAD";
}

+ (NSString *)primaryKey {
    return @"comicId";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = @[
            @"comicId",
            @"title",
            @"author",
            @"thumbUrl",
            @"epsCount",
            @"totalPictures",
            @"downloadedPictures",
            @"createdAt",
            @"updatedAt",
            @"status"
        ];
    });
    return properties;
}

+ (NSArray *)indices {
    // 列表按 createdAt DESC 排序，加索引避免全表扫
    return @[@[@"createdAt"], @[@"status"]];
}

@end
