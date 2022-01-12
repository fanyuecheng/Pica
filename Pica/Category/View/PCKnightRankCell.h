//
//  PCKnightRankCell.h
//  Pica
//
//  Created by YueCheng on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCComicListCell.h"

NS_ASSUME_NONNULL_BEGIN
@class PCUser;
@interface PCKnightRankCell : PCComicListCell

@property (nonatomic, strong) PCUser *user;

- (void)setUser:(PCUser *)user
          index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
