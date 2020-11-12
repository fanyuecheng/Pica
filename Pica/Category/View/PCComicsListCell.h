//
//  PCComicsListCell.h
//  Pica
//
//  Created by fancy on 2020/11/9.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCTableViewCell.h"
#import "PCComics.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicsListCell : PCTableViewCell

@property (nonatomic, strong) PCComics *comics;

@end

NS_ASSUME_NONNULL_END
