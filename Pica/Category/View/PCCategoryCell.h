//
//  PCCategoryCell.h
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCVendorHeader.h"
#import "PCCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCCategoryCell : UICollectionViewCell

@property (nonatomic, strong) SDAnimatedImageView *imageView;
@property (nonatomic, strong) QMUILabel           *titleLabel;
@property (nonatomic, strong) QMUILabel           *iconLabel;
@property (nonatomic, strong) PCCategory *category;

@end

NS_ASSUME_NONNULL_END
