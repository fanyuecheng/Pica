//
//  PCComicsRankCell.h
//  Pica
//
//  Created by 米画师 on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCComicsListCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicsRankCell : PCComicsListCell

- (void)setComics:(PCComics *)comics
            index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
