//
//  UIView+PCAdd.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (PCAdd)

- (void)pc_setShadowWithOpacity:(CGFloat)opacity
                         radius:(CGFloat)radius
                         offset:(CGSize)offset
                          color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
