//
//  PCComicsRankRequest.h
//  Pica
//
//  Created by YueCheng on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PCComicsRankType) {
    PCComicsRankTypeH24,
    PCComicsRankTypeD7,
    PCComicsRankTypeD30
};

@class PCComics;
@interface PCComicsRankRequest : PCRequest

@property (nonatomic, assign) PCComicsRankType type;

- (instancetype)initWithType:(PCComicsRankType)type;

@end

NS_ASSUME_NONNULL_END
