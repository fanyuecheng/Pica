//
//  PCComicRankRequest.h
//  Pica
//
//  Created by YueCheng on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PCComicRankType) {
    PCComicRankTypeH24,
    PCComicRankTypeD7,
    PCComicRankTypeD30
};

@class PCComic;
@interface PCComicRankRequest : PCRequest

@property (nonatomic, assign) PCComicRankType type;

- (instancetype)initWithType:(PCComicRankType)type;

@end

NS_ASSUME_NONNULL_END
