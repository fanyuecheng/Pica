//
//  PCComicHistory.m
//  Pica
//
//  Created by Fancy on 2021/6/7.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCComicHistory.h"
#import "PCComics.h"
#import <YYModel/YYModel.h>
#import "PCLocalKeyHeader.h"

@interface PCComicHistory ()

@property (nonatomic, strong) NSMutableDictionary *cacheDctionary;
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
- (void)saveComic:(PCComics *)comic {
    if (comic.comicsId) {
        NSDictionary *comicJson = [self.cacheDctionary objectForKey:comic.comicsId];
        if (comicJson) {
            [self.cacheArray replaceObjectAtIndex:[self.cacheArray indexOfObject:comicJson] withObject:[comic yy_modelToJSONObject]];
        } else {
            [self.cacheArray insertObject:[comic yy_modelToJSONObject] atIndex:0];
        }
        [kPCUserDefaults setObject:self.cacheArray forKey:PC_DB_COMICS_HISTORY];
    }
}

- (void)deleteComic:(PCComics *)comic {
    if (comic) {
        NSDictionary *comicJson = [self.cacheDctionary objectForKey:comic.comicsId];
        if (comicJson) {
            [self.cacheArray removeObject:comicJson];
            [self.cacheDctionary removeObjectForKey:comic.comicsId];
        }
        [kPCUserDefaults setObject:self.cacheArray forKey:PC_DB_COMICS_HISTORY];
    }
}

- (NSArray <PCComics *>*)allComic {
    NSArray *allComic = [NSArray yy_modelArrayWithClass:[PCComics class] json:self.cacheArray];
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

- (NSMutableDictionary *)cacheDctionary {
    if (!_cacheDctionary) {
        _cacheDctionary = [NSMutableDictionary dictionary];
        if (self.cacheArray.count) {
            [self.cacheArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [_cacheDctionary setObject:obj forKey:obj[@"_id"]];
            }];
        }
    }
    return _cacheDctionary;
}

@end
