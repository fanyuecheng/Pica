//
//  PCComicHistory.m
//  Pica
//
//  Created by Fancy on 2021/6/7.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCComicHistory.h"
#import "PCComic.h"
#import <YYModel/YYModel.h>
#import "PCLocalKeyHeader.h"

@interface PCComicHistory ()

@property (nonatomic, strong) NSMutableArray      *cacheArray;

@end

@implementation PCComicHistory

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PCComicHistory *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

#pragma mark - Method
- (void)saveComic:(PCComic *)comic {
    if (comic.comicId) {
        __block NSDictionary *comicJson = nil;
        [self.cacheArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([comic.comicId isEqualToString:obj[@"_id"]]) {
                comicJson = obj;
                *stop = YES;
            }
        }];
        if (comicJson) {
            [self.cacheArray removeObject:comicJson];
        } else {
            comicJson = [comic yy_modelToJSONObject];
        }
        [self.cacheArray insertObject:comicJson atIndex:0];
        [kPCUserDefaults setObject:self.cacheArray forKey:PC_DB_COMICS_HISTORY];
    }
}

- (void)updateComic:(PCComic *)comic {
    if (comic.comicId) {
        __block NSDictionary *comicJson = nil;
        [self.cacheArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([comic.comicId isEqualToString:obj[@"_id"]]) {
                comicJson = obj;
                *stop = YES;
            }
        }];
        if (comicJson) {
            [self.cacheArray replaceObjectAtIndex:[self.cacheArray indexOfObject:comicJson] withObject:[comic yy_modelToJSONObject]];
        } else {
            [self.cacheArray insertObject:[comic yy_modelToJSONObject] atIndex:0];
        }
        [kPCUserDefaults setObject:self.cacheArray forKey:PC_DB_COMICS_HISTORY];
    }
}


- (void)deleteComic:(PCComic *)comic {
    if (comic) {
        __block NSDictionary *comicJson = nil;
        [self.cacheArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([comic.comicId isEqualToString:obj[@"_id"]]) {
                comicJson = obj;
                *stop = YES;
            }
        }];
        if (comicJson) {
            [self.cacheArray removeObject:comicJson];
        }
        [kPCUserDefaults setObject:self.cacheArray forKey:PC_DB_COMICS_HISTORY];
    }
}

- (PCComic *)comicWithId:(NSString *)comicId {
    __block NSDictionary *comicJson = nil;
    [self.cacheArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([comicId isEqualToString:obj[@"_id"]]) {
            comicJson = obj;
            *stop = YES;
        }
    }];
    return [PCComic yy_modelWithJSON:comicJson];
}

- (NSArray <PCComic *>*)allComic {
    NSArray *allComic = [NSArray yy_modelArrayWithClass:[PCComic class] json:self.cacheArray];
    return allComic;
}

- (void)clearAllComic {
    [self.cacheArray removeAllObjects];
    [kPCUserDefaults removeObjectForKey:PC_DB_COMICS_HISTORY];
}

#pragma mark - Get
- (NSMutableArray *)cacheArray {
    if (!_cacheArray) {
        NSArray *cacheArray = [kPCUserDefaults objectForKey:PC_DB_COMICS_HISTORY];
        if (cacheArray) {
            _cacheArray = [NSMutableArray arrayWithArray:cacheArray];
        } else {
            _cacheArray = [NSMutableArray array];
        }
    }
    return _cacheArray;
}

@end
