//
//  PCGameItemCell.h
//  Pica
//
//  Created by Fancy on 2021/6/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCCategoryCell.h"
#import "PCGame.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCGameItemCell : PCCategoryCell

@property (nonatomic, strong) PCGame *game;

@end

NS_ASSUME_NONNULL_END
