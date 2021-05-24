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

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) QMUILabel   *titleLabel;
@property (nonatomic, strong) QMUILabel   *authorLabel;
@property (nonatomic, strong) QMUILabel   *categoryLabel;
@property (nonatomic, strong) QMUILabel   *likeLabel;

- (UIColor *)colorWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
