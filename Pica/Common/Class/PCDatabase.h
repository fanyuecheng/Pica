//
//  PCDatabase.h
//  Pica
//
//  Created by Fancy on 2021/6/7.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PCComics;
@interface PCDatabase : NSObject

+ (instancetype)sharedInstance;

- (void)saveComic:(PCComics *)comic;
- (void)deleteComic:(PCComics *)comic;
- (NSArray <PCComics *>*)allComic;
- (void)clearAllComic;

@end

NS_ASSUME_NONNULL_END
