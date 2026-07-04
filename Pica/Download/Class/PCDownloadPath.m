//
//  PCDownloadPath.m
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCDownloadPath.h"
#import "PCLocalKeyHeader.h"
#import "PCDefineHeader.h"

@implementation PCDownloadPath

+ (NSString *)rootDirectory {
    static NSString *root = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        root = [documents stringByAppendingPathComponent:PC_DB_COMICS_DOWNLOAD_DIR];
    });
    [self ensureDirectoryExists:root];
    return root;
}

+ (NSString *)directoryForComicId:(NSString *)comicId {
    NSString *dir = [[self rootDirectory] stringByAppendingPathComponent:comicId];
    [self ensureDirectoryExists:dir];
    return dir;
}

+ (NSString *)directoryForComicId:(NSString *)comicId
                            order:(NSInteger)order {
    NSString *dir = [[self directoryForComicId:comicId] stringByAppendingPathComponent:[@(order) stringValue]];
    [self ensureDirectoryExists:dir];
    return dir;
}

+ (NSString *)localPathForComicId:(NSString *)comicId
                            order:(NSInteger)order
                        pageIndex:(NSInteger)pageIndex
                        extension:(NSString *)extension {
    NSString *ext = extension.length ? extension : @"jpg";
    NSString *fileName = [NSString stringWithFormat:@"%03ld.%@", (long)pageIndex, ext];
    return [[self directoryForComicId:comicId order:order] stringByAppendingPathComponent:fileName];
}

+ (NSString *)coverPathForComicId:(NSString *)comicId {
    return [[self directoryForComicId:comicId] stringByAppendingPathComponent:@"cover.jpg"];
}

+ (NSString *)metaPathForComicId:(NSString *)comicId {
    return [[self directoryForComicId:comicId] stringByAppendingPathComponent:@"meta.json"];
}

+ (long long)freeDiskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [kDefaultFileManager attributesOfFileSystemForPath:[self rootDirectory] error:&error];
    if (error || !attrs) {
        return LLONG_MAX;
    }
    NSNumber *free = attrs[NSFileSystemFreeSize];
    return free ? free.longLongValue : LLONG_MAX;
}

+ (long long)totalDownloadFolderSize {
    NSString *root = [self rootDirectory];
    if (![kDefaultFileManager fileExistsAtPath:root]) {
        return 0;
    }
    long long total = 0;
    NSDirectoryEnumerator *enumerator = [kDefaultFileManager enumeratorAtPath:root];
    NSString *subPath = nil;
    while ((subPath = [enumerator nextObject]) != nil) {
        NSString *fullPath = [root stringByAppendingPathComponent:subPath];
        NSDictionary *attrs = [kDefaultFileManager attributesOfItemAtPath:fullPath error:nil];
        if ([attrs.fileType isEqualToString:NSFileTypeRegular]) {
            total += attrs.fileSize;
        }
    }
    return total;
}

#pragma mark - Helper

+ (void)ensureDirectoryExists:(NSString *)path {
    if (![kDefaultFileManager fileExistsAtPath:path]) {
        [kDefaultFileManager createDirectoryAtPath:path
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:nil];
    }
}

@end
