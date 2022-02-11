//
//  PCImageSizeCache.m
//  Pica
//
//  Created by Fancy on 2022/1/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCImageSizeCache.h"
#import "PCVendorHeader.h"
#import "PCDefineHeader.h"
#import "NSData+PCAdd.h"

@interface PCImageSizeCache ()

@property (nonatomic, strong) NSCache       *cache;
@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation PCImageSizeCache

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PCImageSizeCache *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        self.cache = [[NSCache alloc] init];
        self.fileManager = kDefaultFileManager;
        [self creatSizeCacheDirectory];
    }
    return self;
}

#pragma mark - Public
- (BOOL)storeImageSize:(CGSize)size forKey:(NSString *)key {
    if (CGSizeIsInf(size) || CGSizeIsEmpty(size) || !key) {
        return NO;
    }
    NSString *keyName = [key qmui_md5];
    if ([self.cache objectForKey:keyName]) {
        return YES;
    }
    NSDictionary *sizeDictionary = @{@"width" : @(size.width),
                                     @"height" : @(size.height)};
    NSData *data = [sizeDictionary yy_modelToJSONData];
    [self.cache setObject:data forKey:keyName];
    NSString *path = [self sizeCachePathForKey:keyName];
    if ([self.fileManager fileExistsAtPath:path]) {
        return YES;
    } else {
        return [self.fileManager createFileAtPath:path contents:data attributes:nil];
    }
}

- (CGSize)getImageSizeForKey:(NSString *)key {
    NSString *keyName = [key qmui_md5];
    NSData *data = [self.cache objectForKey:keyName];
    if (!data) {
        NSString *path = [self sizeCachePathForKey:keyName];
        data = [self.fileManager contentsAtPath:path];
        if (data) {
            [self.cache setObject:data forKey:keyName];
        }
    }
    if (data) {
        NSDictionary *sizeDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        return CGSizeMake([sizeDictionary[@"width"] floatValue], [sizeDictionary[@"height"] floatValue]);
    } else {
        return CGSizeZero;
    }
}

- (BOOL)containsImageSizeForKey:(NSString *)key {
    NSString *keyName = [key qmui_md5];
    NSData *data = [self.cache objectForKey:keyName];
    if (data) {
        return YES;
    }
    NSString *path = [self sizeCachePathForKey:keyName];
    if ([self.fileManager fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

#pragma mark - Private
- (void)creatSizeCacheDirectory {
    NSString *path = [self sizeCacheDirectory];
    if (![self.fileManager fileExistsAtPath:path]) {
        [self.fileManager createDirectoryAtPath:[self sizeCacheDirectory] withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString *)sizeCachePathForKey:(NSString *)key {
    return [[self sizeCacheDirectory] stringByAppendingPathComponent:key];
}
 
- (NSString *)sizeCacheDirectory {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [libraryPath stringByAppendingPathComponent:@"PCImageSizeCache"];
}

@end

