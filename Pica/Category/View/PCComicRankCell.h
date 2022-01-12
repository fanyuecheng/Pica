//
//  PCComicRankCell.h
//  Pica
//
//  Created by YueCheng on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCComicListCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicRankCell : PCComicListCell

- (void)setComic:(PCComic *)comic
           index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
