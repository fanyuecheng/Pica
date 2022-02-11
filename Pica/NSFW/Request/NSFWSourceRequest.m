//
//  NSFWSourceRequest.m
//  Pica
//
//  Created by Fancy on 2022/2/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "NSFWSourceRequest.h"
#import "PCDefineHeader.h"
#import <SSZipArchive/SSZipArchive.h>

#define kNSFWSourceURL  @"https://github.com/EBazarov/nsfw_data_source_urls/archive/refs/heads/master.zip"

@interface NSFWSourceRequest ()

@property (nonatomic, strong) NSString *sourceDirectory;
@property (nonatomic, strong) NSString *zipPath;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation NSFWSourceRequest

- (NSString *)resumableDownloadPath {
    return self.zipPath;
}

- (NSString *)requestUrl {
    return kNSFWSourceURL;
}

#pragma mark - Method
- (void)startWithCompletionBlockWithSuccess:(YTKRequestCompletionBlock)success failure:(YTKRequestCompletionBlock)failure {
    [super startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        [self unzip];
        !success ? : success(request);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request);
    }];
}

- (BOOL)downloaded {
    return [kDefaultFileManager fileExistsAtPath:self.zipPath];
}

- (void)unzip {
    [SSZipArchive unzipFileAtPath:self.zipPath toDestination:self.filePath];
}

- (NSString *)rootDirectory {
    return [self.sourceDirectory stringByAppendingPathComponent:@"file/nsfw_data_source_urls-master/raw_data"];
}

#pragma mark - Get
- (NSString *)sourceDirectory {
    if (!_sourceDirectory) {
        _sourceDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"NSFWSource"];
        if (![kDefaultFileManager fileExistsAtPath:_sourceDirectory]) {
            [kDefaultFileManager createDirectoryAtPath:_sourceDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _sourceDirectory;
}

- (NSString *)zipPath {
    if (!_zipPath) {
        _zipPath = [self.sourceDirectory stringByAppendingPathComponent:@"source.zip"];
    }
    return _zipPath;
}

- (NSString *)filePath {
    if (!_filePath) {
        _filePath = [self.sourceDirectory stringByAppendingPathComponent:@"file"];
    }
    return _filePath;
}


@end
