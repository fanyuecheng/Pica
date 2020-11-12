//
//  PCPictureCell.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCPicture.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCPictureCell : UICollectionViewCell

@property(nonatomic, copy) void (^loadBlock)(UIImage *image);
@property(nonatomic, copy) void (^clickBlock)(void);

@property (nonatomic, strong) PCPicture *picture;

@end

NS_ASSUME_NONNULL_END
