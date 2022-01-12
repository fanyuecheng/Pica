//
//  PCComicHistory.h
//  Pica
//
//  Created by Fancy on 2021/6/7.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kPCComicHistory  [PCComicHistory sharedInstance]

@class PCComic;
@interface PCComicHistory : NSObject

+ (instancetype)sharedInstance;

- (void)saveComic:(PCComic *)comic;
- (void)updateComic:(PCComic *)comic;
- (void)deleteComic:(PCComic *)comic;
- (PCComic *)comicWithId:(NSString *)comicId;
- (NSArray <PCComic *>*)allComic;
- (void)clearAllComic;

@end

NS_ASSUME_NONNULL_END
